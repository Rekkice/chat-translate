defmodule Chat.Translation do
  @moduledoc """
  Provides functions to handle message translations.
  """

  @api_url "https://api.groq.com/openai/v1/chat/completions"
  @model "llama3-70b-8192"

  @spec translate(String.t()) :: {:ok, map()} | {:error, any()}
  def translate(content) do
    body =
      %{
        messages: [
          %{
            role: "system",
            content:
              "JSON Translate the following into english if it is in spanish, and into spanish if it is in english. Then, return a JSON with the \"english\" and \"spanish\" keys. If it could be seen as offensive, return (filter) for both keys."
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
