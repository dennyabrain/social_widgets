defmodule SocialWidgetsWeb.PollDetailLive do
  use SocialWidgetsWeb, :live_view
  alias SocialWidgets.{Widgets, Polls}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    widget = Widgets.get_widget!(id)

    if widget.widget_type != "poll" do
      {:ok,
       socket
       |> put_flash(:error, "Widget is not a poll")
       |> push_navigate(to: ~p"/")}
    else
      if connected?(socket) do
        Phoenix.PubSub.subscribe(SocialWidgets.PubSub, "poll:#{widget.id}")
      end

      options = Polls.list_poll_options(widget)
      total_votes = Polls.get_total_votes(widget)

      {:ok,
       socket
       |> assign(:widget, widget)
       |> assign(:options, options)
       |> assign(:total_votes, total_votes)
       |> assign(:results, Polls.get_poll_results(widget))}
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
    <Layouts.app flash={@flash}>
      <div class="min-h-screen bg-gray-50">
        <!-- Header -->
        <header class="bg-white border-b border-gray-200">
          <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div class="flex items-center justify-between">
              <div>
                <div class="flex items-center gap-3 mb-2">
                  <.link navigate={~p"/"} class="text-gray-500 hover:text-gray-700">
                    <svg
                      class="w-5 h-5"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M15 19l-7-7 7-7"
                      />
                    </svg>
                  </.link>
                  <h1 class="text-2xl font-semibold text-gray-900">{@widget.name}</h1>
                </div>
                <p class="mt-1 text-sm text-gray-500">Live poll results</p>
              </div>
              <div class="flex gap-3">
                <span class="inline-flex items-center px-3 py-1.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                  <span class="w-2 h-2 bg-green-600 rounded-full mr-2 animate-pulse"></span> Live
                </span>
              </div>
            </div>
          </div>
        </header>
        
    <!-- Main Content -->
        <main class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <!-- Poll Question Card -->
          <div class="bg-white rounded-lg border border-gray-200 p-8 mb-6">
            <h2 class="text-3xl font-semibold text-gray-900 mb-2">
              {@widget.config["question"] || "Poll Question"}
            </h2>
            <p class="text-sm text-gray-500">
              Total votes: <span class="font-semibold text-gray-900">{@total_votes}</span>
            </p>
          </div>
          
    <!-- Results -->
          <div class="bg-white rounded-lg border border-gray-200 p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Results</h3>

            <div class="space-y-6">
              <%= for result <- @results do %>
                <div class="space-y-2">
                  <div class="flex justify-between items-center">
                    <span class="text-sm font-medium text-gray-900">
                      {result.option.text}
                    </span>
                    <div class="flex items-center gap-3">
                      <span class="text-sm text-gray-500">
                        {result.votes} {if result.votes == 1, do: "vote", else: "votes"}
                      </span>
                      <span class="text-sm font-semibold text-gray-900 min-w-[3rem] text-right">
                        {result.percentage}%
                      </span>
                    </div>
                  </div>
                  <div class="w-full bg-gray-200 rounded-full h-4">
                    <div
                      class="bg-gray-900 h-4 rounded-full transition-all duration-300 flex items-center justify-end pr-2"
                      style={"width: #{result.percentage}%"}
                    >
                      <%= if result.percentage > 10 do %>
                        <span class="text-xs font-medium text-white">{result.percentage}%</span>
                      <% end %>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
          
    <!-- Embed Code Section -->
          <div class="bg-white rounded-lg border border-gray-200 p-6 mt-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-3">Embed Code</h3>
            <p class="text-sm text-gray-600 mb-3">
              Copy and paste this code into your HTML to embed the poll:
            </p>
            <div class="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <code class="text-sm text-gray-800 font-mono break-all">
                &lt;iframe src="{SocialWidgetsWeb.Endpoint.url()}/embed/{@widget.embed_code}" width="100%" height="400" frameborder="0"&gt;&lt;/iframe&gt;
              </code>
            </div>
          </div>
        </main>
      </div>
    </Layouts.app>
    """
  end
end
