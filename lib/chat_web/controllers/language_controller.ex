defmodule ChatWeb.LanguageController do
  use ChatWeb, :controller

  alias Chat.Lang
  alias Chat.Lang.Language

  def index(conn, _params) do
    languages = Lang.list_languages()
    render(conn, :index, languages: languages)
  end

  def new(conn, _params) do
    changeset = Lang.change_language(%Language{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"language" => language_params}) do
    case Lang.create_language(language_params) do
      {:ok, language} ->
        conn
        |> put_flash(:info, "Language created successfully.")
        |> redirect(to: ~p"/languages/#{language}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    language = Lang.get_language!(id)
    render(conn, :show, language: language)
  end

  def edit(conn, %{"id" => id}) do
    language = Lang.get_language!(id)
    changeset = Lang.change_language(language)
    render(conn, :edit, language: language, changeset: changeset)
  end

  def update(conn, %{"id" => id, "language" => language_params}) do
    language = Lang.get_language!(id)

    case Lang.update_language(language, language_params) do
      {:ok, language} ->
        conn
        |> put_flash(:info, "Language updated successfully.")
        |> redirect(to: ~p"/languages/#{language}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, language: language, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    language = Lang.get_language!(id)
    {:ok, _language} = Lang.delete_language(language)

    conn
    |> put_flash(:info, "Language deleted successfully.")
    |> redirect(to: ~p"/languages")
  end
end
