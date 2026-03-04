defmodule SocialWidgets.Repo.Migrations.CreateWidgets do
  use Ecto.Migration

  def change do
    create table(:widgets) do
      add :name, :string, null: false
      add :widget_type, :string, null: false
      add :embed_code, :string, null: false
      add :config, :map, default: %{}

      timestamps()
    end

    create unique_index(:widgets, [:embed_code])
    create index(:widgets, [:widget_type])
  end
end
