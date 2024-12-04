defmodule ChatWeb.OgImage.Generator do
  alias Chat.Rooms.Room

  @template_file "/static/og_image_template.svg"

  def generate_image(%Room{url_id: id, lang1: lang1, lang2: lang2}),
    do: generate_image(%{title: id, lang1: lang1, lang2: lang2})

  def generate_image(:home),
    do: generate_image(%{title: "chat-translate", lang1: "Home", lang2: "Page"})

  def generate_image(%{title: title, lang1: lang1, lang2: lang2}) do
    placeholders = %{
      "title" => title,
      "lang1" => lang1,
      "lang2" => lang2
    }

    dir = Application.app_dir(:chat, "priv") <> @template_file

    with {:ok, svg} <- File.read(dir),
         processed_svg <- replace_placeholders(svg, placeholders),
         {:ok, {image, _flags}} <- Vix.Vips.Operation.svgload_buffer(processed_svg) do
      {:ok, image}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected error while generating image"}
    end
  end

  defp replace_placeholders(template, placeholders) do
    pattern = ~r/\{\{(?<key>[a-zA-Z0-9_]+)\}\}/

    Regex.replace(pattern, template, fn _, key ->
      placeholders |> Map.get(key, "")
    end)
  end
end
