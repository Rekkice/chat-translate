defmodule Chat.LangFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chat.Lang` context.
  """

  @doc """
  Generate a language.
  """
  def language_fixture(attrs \\ %{}) do
    {:ok, language} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Chat.Lang.create_language()

    language
  end
end
