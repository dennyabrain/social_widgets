defmodule SocialWidgets.Repo.Migrations.CreateWhiteboardStrokes do
  use Ecto.Migration

  def change do
    create table(:whiteboard_strokes) do
      add :widget_id, references(:widgets, on_delete: :delete_all), null: false
      add :stroke_data, :map, null: false

      timestamps()
    end

    create index(:whiteboard_strokes, [:widget_id])
    create index(:whiteboard_strokes, [:inserted_at])
  end
end
