defmodule SocialWidgets.Widgets.Widget do
  use Ecto.Schema
  import Ecto.Changeset

  schema "widgets" do
    field :name, :string
    field :widget_type, :string
    field :embed_code, :string
    field :config, :map

    timestamps()
  end

  @doc false
  def changeset(widget, attrs) do
    widget
    |> cast(attrs, [:name, :widget_type, :embed_code, :config])
    |> validate_required([:name, :widget_type])
    |> put_embed_code()
    |> unique_constraint(:embed_code)
  end

  defp put_embed_code(changeset) do
    if get_field(changeset, :embed_code) do
      changeset
    else
      embed_code =
        :crypto.strong_rand_bytes(8)
        |> Base.url_encode64(padding: false)
        |> String.slice(0, 12)

      put_change(changeset, :embed_code, embed_code)
    end
  end
end
