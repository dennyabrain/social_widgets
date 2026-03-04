defmodule SocialWidgets.Repo do
  use Ecto.Repo,
    otp_app: :social_widgets,
    adapter: Ecto.Adapters.SQLite3
end
