defmodule ChatWeb.PageController do
  use ChatWeb, :controller

  def home(conn, _params) do
    changeset = Chat.Rooms.change_room(%Chat.Rooms.Room{})
    render(conn, :home, layout: false, changeset: changeset)
  end

  # def redirect_home(conn, _params) do
  #   redirect(conn, to: "/room/1")
  # end
end
