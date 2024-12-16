defmodule ChatWeb.OgImageController do
  require Logger
  alias Chat.Rooms
  use ChatWeb, :controller

  def show_room(conn, %{"id" => id}),
    do:
      Rooms.get_room_by_url_id!(id)
      |> get_or_generate_image
      |> handle_image_response(conn)

  def show_page(conn, %{"page" => "home"}),
    do:
      get_or_generate_image(:home)
      |> handle_image_response(conn)

  defp get_or_generate_image(page) do
    with {:ok, image} <- ChatWeb.OgImage.get_or_generate_image(page),
         {:ok, image_binary} <- Vix.Vips.Image.write_to_buffer(image, ".png[Q=90]") do
      {:ok, image_binary}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp handle_image_response({:ok, image_binary}, conn),
    do: send_image_response(conn, image_binary)

  defp handle_image_response({:error, reason}, conn), do: send_error_response(conn, reason)

  defp send_image_response(conn, image) do
    conn
    |> put_resp_content_type("image/png")
    |> send_resp(200, image)
  end

  defp send_error_response(conn, reason) do
    Logger.error("Failed to generate og image: " <> inspect(reason))

    conn
    |> put_status(:internal_server_error)
    |> json(%{error: reason})
  end
end
