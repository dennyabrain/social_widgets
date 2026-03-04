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
    %WhiteboardStroke{}
    |> WhiteboardStroke.changeset(%{
      widget_id: widget.id,data
    })
    |> Repo.insert()
  end

  @doc """
  Gets all strokes for a widget, ordered by creation time.

  ## Examples

      iex> list_strokes(widget)
      [%WhiteboardStroke{}, ...]

  """
  def list_strokes(widget) do
    Repo.all(
      from s in WhiteboardStroke,
        where: s.widget_id == ^widget.id,
        order_by: [asc: s.inserted_at],
        select: s.stroke_data
    )
  end

  @doc """
  Deletes all strokes for a widget (clear canvas).

  ## Examples

      iex> clear_strokes(widget)
      {5, nil}

  """
  def clear_strokes(widget) do
    Repo.delete_all(
      from s in WhiteboardStroke,
        where: s.widget_id == ^widget.id
    )
  end

  @doc """
  Gets the total number of strokes for a widget.

  ## Examples

      iex> count_strokes(widget)
      42

  """
  def count_strokes(widget) do
    Repo.one(
      from s in WhiteboardStroke,
        where: s.widget_id == ^widget.id,
        select: count(s.id)
    ) || 0
  end
end
