defmodule ChatWeb.RoomController do
  use ChatWeb, :controller

  alias Chat.Rooms

  def create(conn, %{"room" => %{"lang1" => lang1, "lang2" => lang2}}) do
    case Rooms.create_room({lang1, lang2}) do
      {:ok, room} ->
        conn
        |> put_flash(:info, "Room created successfully.")
        |> redirect(to: ~p"/room/#{room.url_id}")

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(
          :error,
          "There was a problem creating the room. Please try again later. If the problem persists, please contact me."
        )
        |> redirect(to: ~p"/")
    end
  end
end
