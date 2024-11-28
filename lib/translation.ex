defmodule Chat.Translation do
  @moduledoc """
  Provides functions to handle message translations.
  """

  @spec translate(String.t(), tuple()) :: {:ok, map()} | {:error, any()}
  def translate(content, {lang1, lang2}) do
    prompt =
      ~s(JSON Translate the following message into these 2 languages: lang1=#{lang1} lang2=#{lang2}. Then, return a JSON with the "lang1" and "lang2" keys and their respective contents. If the content is highly offensive, return [filtered] as a value for both keys. Keep the tone and writing style of the original message, such as capitalization. In the original language, keep the original content, don't alter it.)

    body =
      %{
        messages: [
          %{
            role: "system",
            content: prompt
          },
          %{
            role: "user",
            content: content
          }
        ],
        model: Application.get_env(:chat, Chat.Translation)[:model],
        temperature: 1,
        max_tokens: 1024,
        top_p: 1,
        stream: false,
        response_format: %{
          type: "json_object"
        },
        stop: nil
      }
      |> Jason.encode!()

    api_url = Application.get_env(:chat, Chat.Translation)[:api_url]
    api_key = System.get_env("GROQ_API_KEY")

    case HTTPoison.post(api_url, body, [
           {"Content-Type", "application/json"},
           {"Authorization", "Bearer #{api_key}"}
         ]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"choices" => choices}} ->
            case List.first(choices) do
              %{"message" => %{"content" => json_content}} ->
                {:ok, Jason.decode!(json_content)}

              _ ->
                {:error, "Unexpected response structure"}
            end

          _ ->
            {:error, "Unexpected response structure"}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, %{status_code: status_code, body: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
