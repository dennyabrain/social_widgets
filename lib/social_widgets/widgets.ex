defmodule SocialWidgets.Widgets do
  @moduledoc """
  The Widgets context for managing embeddable social widgets.
  """

  import Ecto.Query, warn: false
  alias SocialWidgets.Repo
  alias SocialWidgets.Widgets.Widget

  @doc """
  Returns the list of widgets.

  ## Examples

      iex> list_widgets()
      [%Widget{}, ...]

  """
  def list_widgets do
    Repo.all(from w in Widget, order_by: [desc: w.inserted_at])
  end

  @doc """
  Gets a single widget.

  Raises `Ecto.NoResultsError` if the Widget does not exist.

  ## Examples

      iex> get_widget!(123)
      %Widget{}

      iex> get_widget!(456)
      ** (Ecto.NoResultsError)

  """
  def get_widget!(id), do: Repo.get!(Widget, id)

  @doc """
  Gets a widget by its embed code.

  ## Examples

      iex> get_widget_by_embed_code("abc123")
      %Widget{}

  """
  def get_widget_by_embed_code(embed_code) do
    Repo.get_by(Widget, embed_code: embed_code)
  end

  @doc """
  Creates a widget with a unique embed code.

  ## Examples

      iex> create_widget(%{name: "My Poll", widget_type: "poll"})
      {:ok, %Widget{}}

      iex> create_widget(%{name: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_widget(attrs \\ %{}) do
    %Widget{}
    |> Widget.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a widget.

  ## Examples

      iex> update_widget(widget, %{name: "Updated Poll"})
      {:ok, %Widget{}}

      iex> update_widget(widget, %{name: nil})
      {:error, %Ecto.Changeset{}}

  """
  def update_widget(%Widget{} = widget, attrs) do
    widget
    |> Widget.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a widget.

  ## Examples

      iex> delete_widget(widget)
      {:ok, %Widget{}}

  """
  def delete_widget(%Widget{} = widget) do
    Repo.delete(widget)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking widget changes.

  ## Examples

      iex> change_widget(widget)
      %Ecto.Changeset{data: %Widget{}}

  """
  def change_widget(%Widget{} = widget, attrs \\ %{}) do
    Widget.changeset(widget, attrs)
  end

  @doc """
  Generates a unique embed code for widgets.
  """
  def generate_embed_code do
    :crypto.strong_rand_bytes(8)
    |> Base.url_encode64(padding: false)
    |> binary_part(0, 12)
  end
end
