defmodule ChatWeb.Plugs.MetaTags do
  import Plug.Conn

  def init(default), do: default

  # default values for meta tags
  def call(conn, _opts) do
    conn
    |> assign(:page_title, "a page")
    |> assign(
      :og_description,
      "A chat app designed to bridge the language gap between a group of people, by using the power of AI to provide context-aware translations for every message in real-time."
    )
    |> assign(:og_image, "/og/home")
  end
end
