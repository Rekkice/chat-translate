defmodule ChatWeb.OgImage.Generator do
  alias Chat.Rooms.Room
  require EEx

  @template_file "lib/chat_web/og_image/og_image_template.eex"

  def generate_image(%Room{url_id: id, lang1: lang1, lang2: lang2}),
    do: generate_image(%{title: id, lang1: lang1, lang2: lang2})

  def generate_image(:home),
    do: generate_image(%{title: "chat-translate", lang1: "Home", lang2: "Page"})

  def generate_image(%{title: title, lang1: lang1, lang2: lang2}) do
    placeholders = %{
      title: title,
      lang1: lang1,
      lang2: lang2
    }

    processed_svg =
      replace_placeholders(placeholders)

    case Vix.Vips.Operation.svgload_buffer(processed_svg) do
      {:ok, {image, _flags}} -> {:ok, image}
      {:error, reason} -> {:error, reason}
    end
  end

  EEx.function_from_file(
    :def,
    :replace_placeholders,
    @template_file,
    [:assigns]
  )
end
