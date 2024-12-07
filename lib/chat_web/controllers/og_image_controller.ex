defmodule ChatWeb.OgImageController do
  alias Chat.Rooms
  use ChatWeb, :controller

  def show(conn, %{"id" => id}) do
    room = Rooms.get_room_by_url_id!(id)

    case ChatWeb.OgImage.get_or_generate_image(room) do
      {:ok, image} ->
        {:ok, image_binary} = image |> Vix.Vips.Image.write_to_buffer(".png[Q=90]")
        send_image_response(conn, image_binary)

      {:error, reason} ->
        IO.inspect("failed to generate image, sending response")
        send_error_response(conn, reason)
    end
  end

  defp send_image_response(conn, image) do
    conn
    |> put_resp_content_type("image/png")
    |> send_resp(200, image)
  end

  defp send_error_response(conn, reason) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{error: reason})
  end
end
