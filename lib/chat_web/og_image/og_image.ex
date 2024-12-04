defmodule ChatWeb.OgImage do
  alias Chat.Rooms.Room
  alias ChatWeb.OgImage.Generator
  alias ChatWeb.OgImage.Cache

  def get_or_generate_image(%Room{url_id: id} = room),
    do: get_or_generate_image(id, fn -> Generator.generate_image(room) end)

  def get_or_generate_image(:home),
    do: get_or_generate_image(:home, fn -> Generator.generate_image(:home) end)

  defp get_or_generate_image(key, generate_image_fun) do
    case Cache.get_image(key) do
      {:ok, image} ->
        {:ok, image}

      :error ->
        with {:ok, image} <- generate_image_fun.() do
          Cache.put_image(key, image)
          {:ok, image}
        else
          {:error, reason} -> {:error, reason}
        end
    end
  end
end
