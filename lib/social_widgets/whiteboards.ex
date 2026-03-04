defmodule SocialWidgets.Whiteboards.WhiteboardStroke do
  use Ecto.Schema
  import Ecto.Changeset

  schema "whiteboard_strokes" do
    field :stroke_data, :map

    belongs_to :widget, SocialWidgets.Widgets.Widget

    timestamps()
  end

  @doc false
  def changeset(whiteboard_stroke, attrs) do
    whiteboard_stroke
    |> cast(attrs, [:widget_id, :stroke_data])
    |> validate_required([:widget_id, :stroke_data])
  end
end

defmodule SocialWidgets.Whiteboards do
  @moduledoc """
  The Whiteboards context for managing collaborative whiteboard widgets.
  """

  import Ecto.Query, warn: false
  alias SocialWidgets.Repo
  alias SocialWidgets.Whiteboards.WhiteboardStroke

  @doc """
  Saves a stroke to the database.

  ## Examples

      iex> save_stroke(widget, stroke_data)
      {:ok, %WhiteboardStroke{}}

  """
  def save_stroke(widget, stroke_data) do
    %White