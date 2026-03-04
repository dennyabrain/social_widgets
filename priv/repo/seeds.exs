# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SocialWidgets.Repo.insert!(%SocialWidgets.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias SocialWidgets.Widgets
alias SocialWidgets.Polls

# Clear existing widgets
SocialWidgets.Repo.delete_all(SocialWidgets.Widgets.Widget)

# Create sample poll widget
{:ok, widget} =
  Widgets.create_widget(%{
    name: "Favorite Programming Language Poll",
    widget_type: "poll",
    config: %{
      question: "What's your favorite programming language?",
      options: ["Elixir", "JavaScript", "Python", "Rust", "Go"]
    }
  })

IO.puts("✓ Seeded sample poll widget")

# Create poll options for the widget
{:ok, _options} =
  Polls.create_poll_options(widget, [
    "Elixir",
    "JavaScript",
    "Python",
    "Rust",
    "Go"
  ])

IO.puts("✓ Seeded sample poll options")

# Create sample whiteboard widget
{:ok, whiteboard} =
  Widgets.create_widget(%{
    name: "Collaborative Drawing Board",
    widget_type: "whiteboard"
  })

IO.puts("✓ Seeded sample whiteboard widget")
