defmodule SocialWidgets.Polls.PollOption do
  use Ecto.Schema
  import Ecto.Changeset

  schema "poll_options" do
    field :text, :string
    field :votes_count, :integer, default: 0

    belongs_to :widget, SocialWidgets.Widgets.Widget

    timestamps()
  end

  @doc false
  def changeset(poll_option, attrs) do
    poll_option
    |> cast(attrs, [:text, :widget_id, :votes_count])
    |> validate_required([:text, :widget_id])
  end
end

defmodule SocialWidgets.Polls.PollVote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "poll_votes" do
    field :voter_id, :string

    belongs_to :poll_option, SocialWidgets.Polls.PollOption

    timestamps()
  end

  @doc false
  def changeset(poll_vote, attrs) do
    poll_vote
    |> cast(attrs, [:poll_option_id, :voter_id])
    |> validate_required([:poll_option_id, :voter_id])
    |> unique_constraint([:poll_option_id, :voter_id])
  end
end

defmodule SocialWidgets.Polls do
  @moduledoc """
  The Polls context for managing poll widgets, options, and votes.
  """

  import Ecto.Query, warn: false
  alias SocialWidgets.Repo
  alias SocialWidgets.Polls.{PollOption, PollVote}
  alias SocialWidgets.Widgets
  alias SocialWidgets.Polls.{PollOption, PollVote}

  @doc """
  Creates poll options for a widget.

  ## Examples

      iex> create_poll_options(widget, ["Option 1", "Option 2"])
      {:ok, [%PollOption{}, %PollOption{}]}

  """
  def create_poll_options(widget, option_texts) when is_list(option_texts) do
    options =
      Enum.map(option_texts, fn text ->
        %PollOption{widget_id: widget.id, text: text}
        |> Repo.insert!()
      end)

    {:ok, options}
  end

  @doc """
  Gets all options for a poll widget.

  ## Examples

      iex> list_poll_options(widget)
      [%PollOption{}, ...]

  """
  def list_poll_options(widget) do
    Repo.all(
      from o in PollOption,
        where: o.widget_id == ^widget.id,
        order_by: [asc: o.id]
    )
  end

  @doc """
  Casts a vote for a poll option.
  Uses voter_id to prevent duplicate votes from the same voter.

  ## Examples

      iex> vote(poll_option_id, voter_id)
      {:ok, %PollVote{}}

      iex> vote(poll_option_id, voter_id)
      {:error, :already_voted}

  """
  def vote(poll_option_id, voter_id) do
    # Check if voter has already voted for this option
    existing_vote =
      Repo.get_by(PollVote, poll_option_id: poll_option_id, voter_id: voter_id)

    if existing_vote do
      {:error, :already_voted}
    else
      # Insert vote and increment counter in a transaction
      Repo.transaction(fn ->
        vote =
          %PollVote{poll_option_id: poll_option_id, voter_id: voter_id}
          |> Repo.insert!()

        # Increment votes_count
        from(o in PollOption, where: o.id == ^poll_option_id)
        |> Repo.update_all(inc: [votes_count: 1])

        vote
      end)
      |> case do
        {:ok, vote} -> {:ok, vote}
        {:error, _} -> {:error, :vote_failed}
      end
    end
  end

  @doc """
  Checks if a voter has already voted on any option in a poll.

  ## Examples

      iex> has_voted?(widget, voter_id)
      true

  """
  def has_voted?(widget, voter_id) do
    option_ids =
      from(o in PollOption, where: o.widget_id == ^widget.id, select: o.id)
      |> Repo.all()

    Repo.exists?(
      from v in PollVote,
        where: v.poll_option_id in ^option_ids and v.voter_id == ^voter_id
    )
  end

  @doc """
  Gets the total number of votes for a poll widget.

  ## Examples

      iex> get_total_votes(widget)
      42

  """
  def get_total_votes(widget) do
    Repo.one(
      from o in PollOption,
        where: o.widget_id == ^widget.id,
        select: sum(o.votes_count)
    ) || 0
  end

  @doc """
  Gets poll results with percentages.

  ## Examples

      iex> get_poll_results(widget)
      [%{option: %PollOption{}, votes: 10, percentage: 33.3}, ...]

  """
  def get_poll_results(widget) do
    options = list_poll_options(widget)
    total_votes = get_total_votes(widget)

    Enum.map(options, fn option ->
      percentage =
        if total_votes > 0 do
          Float.round(option.votes_count / total_votes * 100, 1)
        else
          0.0
        end

      %{
        option: option,
        votes: option.votes_count,
        percentage: percentage
      }
    end)
  end
end
