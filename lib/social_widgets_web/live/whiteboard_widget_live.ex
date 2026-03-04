defmodule SocialWidgetsWeb.WhiteboardWidgetLive do
  use SocialWidgetsWeb, :live_view
  alias SocialWidgets.{Widgets, Whiteboards}

  @impl true
  def mount(%{"embed_code" => embed_code}, _session, socket) do
    widget = Widgets.get_widget_by_embed_code(embed_code)

    if widget && widget.widget_type == "whiteboard" do
      if connected?(socket) do
        Phoenix.PubSub.subscribe(SocialWidgets.PubSub, "whiteboard:#{widget.id}")
      end

      strokes = Whiteboards.list_strokes(widget)

      {:ok,
       socket
       |> assign(:widget, widget)
       |> assign(:strokes, strokes)
       |> assign(:selected_color, "#000000")
       |> assign(:stroke_width, 3)}
    else
      {:ok,
       socket
       |> put_flash(:error, "Whiteboard not found")
       |> assign(:widget, nil)}
    end
  end

  @impl true
  def handle_event("draw_stroke", %{"stroke" => stroke_data}, socket) do
    widget = socket.assigns.widget

    # Save stroke to database
    {:ok, _stroke} = Whiteboards.save_stroke(widget, stroke_data)

    # Broadcast stroke to all connected viewers
    Phoenix.PubSub.broadcast(
      SocialWidgets.PubSub,
      "whiteboard:#{widget.id}",
      {:new_stroke, widget.id, stroke_data}
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_canvas", _params, socket) do
    widget = socket.assigns.widget

    # Clear all strokes from database
    Whiteboards.clear_strokes(widget)

    # Broadcast clear event to all connected viewers
    Phoenix.PubSub.broadcast(
      SocialWidgets.PubSub,
      "whiteboard:#{widget.id}",
      {:clear_canvas, widget.id}
    )

    {:noreply, assign(socket, :strokes, [])}
  end

  @impl true
  def handle_event("change_color", %{"color" => color}, socket) do
    {:noreply, assign(socket, :selected_color, color)}
  end

  @impl true
  def handle_event("change_width", %{"width" => width}, socket) do
    {:noreply, assign(socket, :stroke_width, String.to_integer(width))}
  end

  @impl true
  def handle_info({:new_stroke, widget_id, stroke_data}, socket) do
    if socket.assigns.widget.id == widget_id do
      # Push event to JS hook to draw the stroke
      {:noreply, push_event(socket, "draw_remote_stroke", %{stroke: stroke_data})}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:clear_canvas, widget_id}, socket) do
    if socket.assigns.widget.id == widget_id do
      {:noreply,
       socket
       |> assign(:strokes, [])
       |> push_event("clear_canvas", %{})}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white p-6">
      <%= if @widget do %>
        <div class="max-w-4xl mx-auto">
          <div class="mb-4 flex items-center justify-between">
            <h2 class="text-2xl font-semibold text-gray-900">
              {@widget.name}
            </h2>
            <div class="flex gap-2">
              <button
                phx-click="clear_canvas"
                class="px-3 py-2 text-sm text-red-600 border border-red-300 rounded-lg hover:bg-red-50 transition-colors"
              >
                Clear Canvas
              </button>
            </div>
          </div>
          
    <!-- Drawing Tools -->
          <div class="bg-gray-50 rounded-lg p-4 mb-4 flex items-center gap-4">
            <div class="flex items-center gap-2">
              <label class="text-sm font-medium text-gray-700">Color:</label>
              <input
                type="color"
                value={@selected_color}
                phx-change="change_color"
                name="color"
                class="w-10 h-10 border border-gray-300 rounded cursor-pointer"
              />
            </div>

            <div class="flex items-center gap-2">
              <label class="text-sm font-medium text-gray-700">Width:</label>
              <input
                type="range"
                min="1"
                max="20"
                value={@stroke_width}
                phx-change="change_width"
                name="width"
                class="w-32"
              />
              <span class="text-sm text-gray-600 min-w-[2rem]">{@stroke_width}px</span>
            </div>
          </div>
          
    <!-- Canvas -->
          <div class="border-2 border-gray-300 rounded-lg overflow-hidden bg-white">
            <canvas
              id="whiteboard-canvas"
              phx-hook="WhiteboardCanvas"
              data-strokes={Jason.encode!(@strokes)}
              data-color={@selected_color}
              data-width={@stroke_width}
              width="800"
              height="600"
              class="w-full cursor-crosshair"
            />
          </div>
        </div>
      <% else %>
        <div class="max-w-2xl mx-auto text-center">
          <p class="text-gray-500">Whiteboard not found</p>
        </div>
      <% end %>
    </div>
    """
  end
end
