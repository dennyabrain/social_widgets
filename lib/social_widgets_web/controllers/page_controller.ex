defmodule SocialWidgetsWeb.PageController do
  use SocialWidgetsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
