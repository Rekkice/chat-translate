defmodule ChatWeb.PageController do
  use ChatWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def redirect_home(conn, _params) do
    redirect(conn, to: "/room/1")
  end
end
