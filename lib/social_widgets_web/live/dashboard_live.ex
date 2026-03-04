defmodule SocialWidgetsWeb.DashboardLive do
  use SocialWidgetsWeb, :live_view
  alias SocialWidgets.{Widgets, Polls}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(SocialWidgets.PubSub, "widgets")
    end

    widgets = Widgets.list_widgets()

    {:ok,
     socket
     |> assign(:widgets, widgets)
     |> assign(:widget_form, to_form(Widgets.change_widget(%Widgets.Widget{})))
     |> assign(:show_form, false)
     |> assign(:selected_widget, nil)
     |> assign(:poll_question, "")
     |> assign(:poll_options, ["", "", "", ""])}
  end

  @impl true
  def handle_event("toggle_form", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_form, !socket.assigns.show_form)
     |> assign(:poll_question, "")
     |> assign(:poll_options, ["", "", "", ""])}
  end

  @impl true
  def handle_event("validate", %{"widget" => widget_params}, socket) do
    changeset =
      %Widgets.Widget{}
      |> Widgets.Widget.changeset(widget_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :widget_form, to_form(changeset))}
  end

  @impl true
  def handle_event("update_poll_question", params, socket) do
    question = params["value"] || Map.get(params, "poll_question", "")
    {:noreply, assign(socket, :poll_question, question)}
  end

  @impl true
  def handle_event("update_poll_option", params, socket) do
    index =
      case params["index"] do
        i when is_integer(i) -> i
        i when is_binary(i) -> String.to_integer(i)
        _ -> 0
      end

    value = params["value"] || ""
    poll_options = List.replace_at(socket.assigns.poll_options, index, value)
    {:noreply, assign(socket, :poll_options, poll_options)}
  end

  @impl true
  def handle_event("add_poll_option", _params, socket) do
    poll_options = socket.assigns.poll_options ++ [""]
    {:noreply, assign(socket, :poll_options, poll_options)}
  end

  @impl true
  def handle_event("remove_poll_option", %{"index" => index}, socket) do
    poll_options = List.delete_at(socket.assigns.poll_options, index)
    {:noreply, assign(socket, :poll_options, poll_options)}
  end

  @impl true
  def handle_event("save", %{"widget" => widget_params}, socket) do
    widget_type = Map.get(widget_params, "widget_type", "poll")

    widget_params_with_config =
      if widget_type == "poll" do
        options = Enum.filter(socket.assigns.poll_options, &(&1 != ""))

        if socket.assigns.poll_question == "" || length(options) < 2 do
          changeset =
            %Widgets.Widget{}
            |> Widgets.Widget.changeset(widget_params)
            |> Ecto.Changeset.add_error(
              :config,
              "Poll must have a question and at least 2 options"
            )

          {:error, changeset}
        else
          config = %{
            "question" => socket.assigns.poll_question,
            "options" => options
          }

          {:ok, Map.put(widget_params, "config", config)}
        end
      else
        {:ok, widget_params}
      end

    case widget_params_with_config do
      {:ok, params} ->
        case Widgets.create_widget(params) do
          {:ok, widget} ->
            # Create poll options if it's a poll widget
            if widget.widget_type == "poll" do
              option_texts = widget.config["options"]
              Polls.create_poll_options(widget, option_texts)
            end

            Phoenix.PubSub.broadcast(
              SocialWidgets.PubSub,
              "widgets",
              {:widget_created, widget}
            )

            {:noreply,
             socket
             |> put_flash(:info, "Widget created successfully!")
             |> assign(:show_form, false)
             |> assign(:widget_form, to_form(Widgets.change_widget(%Widgets.Widget{})))
             |> assign(:poll_question, "")
             |> assign(:poll_options, ["", "", "", ""])
             |> assign(:widgets, Widgets.list_widgets())}

          {:error, changeset} ->
            {:noreply, assign(socket, :widget_form, to_form(changeset))}
        end

      {:error, changeset} ->
        {:noreply, assign(socket, :widget_form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("delete_widget", %{"id" => id}, socket) do
    widget = Widgets.get_widget!(id)
    {:ok, _} = Widgets.delete_widget(widget)

    Phoenix.PubSub.broadcast(SocialWidgets.PubSub, "widgets", {:widget_deleted, widget})

    {:noreply,
     socket
     |> put_flash(:info, "Widget deleted successfully")
     |> assign(:widgets, Widgets.list_widgets())}
  end

  @impl true
  def handle_event("show_embed_code", %{"id" => id}, socket) do
    widget = Widgets.get_widget!(id)
    {:noreply, assign(socket, :selected_widget, widget)}
  end

  @impl true
  def handle_event("close_embed_modal", _params, socket) do
    {:noreply, assign(socket, :selected_widget, nil)}
  end

  @impl true
  def handle_info({:widget_created, _widget}, socket) do
    {:noreply, assign(socket, :widgets, Widgets.list_widgets())}
  end

  @impl true
  def handle_info({:widget_deleted, _widget}, socket) do
    {:noreply, assign(socket, :widgets, Widgets.list_widgets())}
  end
end
