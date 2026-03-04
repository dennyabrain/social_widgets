defmodule SocialWidgetsWeb.DashboardLive do
  use SocialWidgetsWeb, :live_view
  alias SocialWidgets.Widgets

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
     |> assign(:selected_widget, nil)}
  end

  @impl true
  def handle_event("toggle_form", _params, socket) do
    {:noreply, assign(socket, :show_form, !socket.assigns.show_form)}
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
  def handle_event("save", %{"widget" => widget_params}, socket) do
    case Widgets.create_widget(widget_params) do
      {:ok, widget} ->
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
         |> assign(:widgets, Widgets.list_widgets())}

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
