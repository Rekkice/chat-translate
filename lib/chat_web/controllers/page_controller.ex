defmodule ChatWeb.PageController do
  use ChatWeb, :controller

  def home(conn, _params) do
    changeset = Chat.Rooms.change_room(%Chat.Rooms.Room{})
    languages = Application.get_env(:chat, Chat.Rooms)[:languages]
    default_languages = Application.get_env(:chat, Chat.Rooms)[:default_languages]

    IO.inspect("languages:")
    IO.inspect(languages)

    render(conn, :home,
      layout: false,
      changeset: changeset,
      languages: languages,
      default_languages: default_languages
    )
  end

  # def redirect_home(conn, _params) do
  #   redirect(conn, to: "/room/1")
  # end
end
