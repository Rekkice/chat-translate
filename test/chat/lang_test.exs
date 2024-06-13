defmodule Chat.LangTest do
  use Chat.DataCase

  alias Chat.Lang

  describe "languages" do
    alias Chat.Lang.Language

    import Chat.LangFixtures

    @invalid_attrs %{name: nil}

    test "list_languages/0 returns all languages" do
      language = language_fixture()
      assert Lang.list_languages() == [language]
    end

    test "get_language!/1 returns the language with given id" do
      language = language_fixture()
      assert Lang.get_language!(language.id) == language
    end

    test "create_language/1 with valid data creates a language" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Language{} = language} = Lang.create_language(valid_attrs)
      assert language.name == "some name"
    end

    test "create_language/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lang.create_language(@invalid_attrs)
    end

    test "update_language/2 with valid data updates the language" do
      language = language_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Language{} = language} = Lang.update_language(language, update_attrs)
      assert language.name == "some updated name"
    end

    test "update_language/2 with invalid data returns error changeset" do
      language = language_fixture()
      assert {:error, %Ecto.Changeset{}} = Lang.update_language(language, @invalid_attrs)
      assert language == Lang.get_language!(language.id)
    end

    test "delete_language/1 deletes the language" do
      language = language_fixture()
      assert {:ok, %Language{}} = Lang.delete_language(language)
      assert_raise Ecto.NoResultsError, fn -> Lang.get_language!(language.id) end
    end

    test "change_language/1 returns a language changeset" do
      language = language_fixture()
      assert %Ecto.Changeset{} = Lang.change_language(language)
    end
  end
end
