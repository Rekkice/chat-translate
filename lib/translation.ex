defmodule Chat.Translation do
  @moduledoc """
  Provides functions to handle message translations.
  """

  @api_url "https://api.groq.com/openai/v1/chat/completions"
  @model "llama3-70b-8192"

  @spec translate(String.t(), tuple()) :: {:ok, map()} | {:error, any()}
  def translate(content, {lang1, lang2}) do
    prompt =
      ~s(JSON Translate the following message into these 2 languages: lang1=#{lang1} lang2=#{lang2}. Then, return a JSON with the "lang1" and "lang2" keys and their respective contents. If it could be seen as offensive, return [filtered] as a value for both keys. Keep the tone and writing style of the original message.)

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
        model: @model,
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

    case HTTPoison.post(@api_url, body, [
           {"Content-Type", "application/json"},
           {"Authorization", "Bearer #{System.get_env("GROQ_API_KEY")}"}
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
