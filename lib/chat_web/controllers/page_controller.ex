defmodule ChatWeb.PageController do
  use ChatWeb, :controller

  def home(conn, _params) do
    changeset = Chat.Rooms.change_room(%Chat.Rooms.Room{})
    languages = Application.get_env(:chat, Chat.Rooms)[:languages]
    default_languages = Application.get_env(:chat, Chat.Rooms)[:default_languages]

    {_, metrics} = ChatWeb.UserCache.get_metrics()
    %{rooms: room_count, messages: message_count} = metrics

    render(conn, :home,
      layout: false,
      changeset: changeset,
      languages: languages,
      default_languages: default_languages,
      page_title: "home",
      room_count: room_count,
      message_count: message_count
    )
  end
end
