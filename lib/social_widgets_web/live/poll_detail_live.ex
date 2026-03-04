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
      <div class="min-h-screen bg-gradient-to-br from-[#f5f3e8] via-[#e8f4f5] to-[#d0cd94]/20">
        <!-- Header -->
        <header class="bg-gradient-to-r from-[#241623] to-[#3c787e] border-b-4 border-[#c7ef00]">
          <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-4">
                <.link navigate={~p"/"} class="text-white hover:text-[#c7ef00] transition-colors">
                  <svg
                    class="w-6 h-6"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                    stroke-width="3"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
                  </svg>
                </.link>
                <div>
                  <h1 class="text-2xl font-bold text-white drop-shadow-lg">📊 {@widget.name}</h1>
                  <p class="mt-1 text-sm text-[#d0cd94] font-medium">Live poll results ✨</p>
                </div>
              </div>
              <span class="inline-flex items-center px-4 py-2 rounded-full text-sm font-bold bg-[#c7ef00] text-[#241623] border-2 border-white shadow-lg">
                <span class="w-2 h-2 bg-[#241623] rounded-full mr-2 animate-pulse"></span> LIVE
              </span>
            </div>
          </div>
        </header>
        
    <!-- Main Content -->
        <main class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <!-- Poll Question Card -->
          <div class="bg-white rounded-2xl border-4 border-[#3c787e] p-8 mb-6 shadow-xl">
            <h2 class="text-3xl font-bold text-[#241623] mb-3">
              {@widget.config["question"] || "Poll Question"}
            </h2>
            <p class="text-base text-[#3c787e] font-medium">
              Total votes: <span class="font-black text-[#241623]">{@total_votes}</span> 🗳️
            </p>
          </div>
          
    <!-- Results -->
          <div class="bg-white rounded-2xl border-4 border-[#241623] p-6 shadow-xl">
            <h3 class="text-xl font-black text-[#241623] mb-6">📊 Results</h3>

            <div class="space-y-6">
              <%= for result <- @results do %>
                <div class="space-y-2">
                  <div class="flex justify-between items-center">
                    <span class="text-base font-bold text-[#241623]">
                      {result.option.text}
                    </span>
                    <div class="flex items-center gap-3">
                      <span class="text-sm text-[#3c787e] font-medium">
                        {result.votes} {if result.votes == 1, do: "vote", else: "votes"}
                      </span>
                      <span class="text-base font-black text-[#241623] min-w-[3.5rem] text-right px-3 py-1 bg-[#c7ef00] rounded-lg border-2 border-[#241623]">
                        {result.percentage}%
                      </span>
                    </div>
                  </div>
                  <div class="w-full bg-[#d0cd94]/30 rounded-full h-6 border-2 border-[#3c787e]">
                    <div
                      class="bg-gradient-to-r from-[#3c787e] to-[#c7ef00] h-full rounded-full transition-all duration-500 flex items-center justify-end pr-3"
                      style={"width: #{result.percentage}%"}
                    >
                      <%= if result.percentage > 15 do %>
                        <span class="text-xs font-black text-white drop-shadow">
                          {result.percentage}%
                        </span>
                      <% end %>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </main>
      </div>
    </Layouts.app>
    """
  end
end
