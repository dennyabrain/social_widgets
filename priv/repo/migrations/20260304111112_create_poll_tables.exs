defmodule SocialWidgets.Repo.Migrations.CreatePollTables do
  use Ecto.Migration

  def change do
    create table(:poll_options) do
      add :widget_id, references(:widgets, on_delete: :delete_all), null: false
      add :text, :string, null: false
      add :votes_count, :integer, default: 0, null: false

      timestamps()
    end

    create table(:poll_votes) do
      add :poll_option_id, references(:poll_options, on_delete: :delete_all), null: false
      add :voter_id, :string, null: false

      timestamps()
    end

    create index(:poll_options, [:widget_id])
    create index(:poll_votes, [:poll_option_id])
    create unique_index(:poll_votes, [:poll_option_id, :voter_id])
  end
end
