defmodule SocialWidgetsWeb.PollWidgetLive do
  use SocialWidgetsWeb, :live_view
  alias SocialWidgets.{Widgets, Polls}

  @impl true
  def mount(%{"embed_code" => embed_code}, _session, socket) do
    widget = Widgets.get_widget_by_embed_code(embed_code)

    if widget && widget.widget_type == "poll" do
      if connected?(socket) do
        Phoenix.PubSub.subscribe(SocialWidgets.PubSub, "poll:#{widget.id}")
      end

      options = Polls.list_poll_options(widget)
      total_votes = Polls.get_total_votes(widget)

      # Generate a unique voter ID based on session
      voter_id = get_voter_id(socket)
      has_voted = Polls.has_voted?(widget, voter_id)

      {:ok,
       socket
       |> assign(:widget, widget)
       |> assign(:options, options)
       |> assign(:total_votes, total_votes)
       |> assign(:voter_id, voter_id)
       |> assign(:has_voted, has_voted)
       |> assign(:results, Polls.get_poll_results(widget))}
    else
      {:ok,
       socket
       |> put_flash(:error, "Poll not found")
       |> assign(:widget, nil)}
    end
  end

  @impl true
  def handle_event("vote", %{"option_id" => option_id}, socket) do
    option_id = String.to_integer(option_id)
    voter_id = socket.assigns.voter_id

    case Polls.vote(option_id, voter_id) do
      {:ok, _vote} ->
        widget = socket.assigns.widget

        # Broadcast vote update to all connected viewers
        Phoenix.PubSub.broadcast(
          SocialWidgets.PubSub,
          "poll:#{widget.id}",
          {:vote_updated, widget.id}
        )

        {:noreply,
         socket
         |> assign(:has_voted, true)
         |> assign(:options, Polls.list_poll_options(widget))
         |> assign(:total_votes, Polls.get_total_votes(widget))
         |> assign(:results, Polls.get_poll_results(widget))}

      {:error, :already_voted} ->
        {:noreply, put_flash(socket, :error, "You've already voted!")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to record vote")}
    end
  end

  @impl true
  def handle_info({:vote_updated, widget_id}, socket) do
    if socket.assigns.widget.id == widget_id do
      widget = socket.assigns.widget

      {:noreply,
       socket
       |> assign(:options, Polls.list_poll_options(widget))
       |> assign(:total_votes, Polls.get_total_votes(widget))
       |> assign(:results, Polls.get_poll_results(widget))}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white p-6">
      <%= if @widget do %>
        <div class="max-w-2xl mx-auto">
          <h2 class="text-2xl font-semibold text-gray-900 mb-6">
            {@widget.config["question"] || "Poll"}
          </h2>

          <%= if @has_voted do %>
            <!-- Results View -->
            <div class="space-y-4">
              <%= for result <- @results do %>
                <div class="space-y-2">
                  <div class="flex justify-between items-center">
                    <span class="text-sm font-medium text-gray-700">
                      {result.option.text}
                    </span>
                    <span class="text-sm text-gray-500">
                      {result.votes} votes ({result.percentage}%)
                    </span>
                  </div>
                  <div class="w-full bg-gray-200 rounded-full h-3">
                    <div
                      class="bg-gray-900 h-3 rounded-full transition-all duration-300"
                      style={"width: #{result.percentage}%"}
                    />
                  </div>
                </div>
              <% end %>
              <p class="text-sm text-gray-500 mt-4">Total votes: {@total_votes}</p>
            </div>
          <% else %>
            <!-- Voting View -->
            <div class="space-y-3">
              <%= for option <- @options do %>
                <button
                  phx-click="vote"
                  phx-value-option_id={option.id}
                  class="w-full px-4 py-3 text-left border-2 border-gray-200 rounded-lg hover:border-gray-900 hover:bg-gray-50 transition-all text-gray-900 font-medium"
                >
                  {option.text}
                </button>
              <% end %>
            </div>
          <% end %>
        </div>
      <% else %>
        <div class="max-w-2xl mx-auto text-center">
          <p class="text-gray-500">Poll not found</p>
        </div>
      <% end %>
    </div>
    """
  end

  defp get_voter_id(socket) do
    # Generate a simple voter ID from the LiveView session
    # In production, you might want to use browser fingerprinting or similar
    "voter_#{:erlang.phash2(socket.id)}"
  end
end
