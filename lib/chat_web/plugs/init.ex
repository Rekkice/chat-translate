defmodule ChatWeb.Plugs.Init do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _opts) do
    conn
    |> default_meta_tags
    |> init_id
  end

  defp default_meta_tags(conn) do
    conn
    |> assign(:page_title, "a page")
    |> assign(
      :og_description,
      "A chat app designed to bridge the language gap between a group of people, by using the power of AI to provide context-aware translations for every message in real-time."
    )
    |> assign(:og_image, "/og/home")
  end

  defp init_id(conn) do
    case get_session(conn, :id) do
      nil -> conn |> put_session(:id, Ecto.UUID.generate)
      _ -> conn
    end
  end
end

