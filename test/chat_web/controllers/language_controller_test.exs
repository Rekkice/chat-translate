defmodule ChatWeb.LanguageControllerTest do
  use ChatWeb.ConnCase

  import Chat.LangFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all languages", %{conn: conn} do
      conn = get(conn, ~p"/languages")
      assert html_response(conn, 200) =~ "Listing Languages"
    end
  end

  describe "new language" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/languages/new")
      assert html_response(conn, 200) =~ "New Language"
    end
  end

  describe "create language" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/languages", language: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/languages/#{id}"

      conn = get(conn, ~p"/languages/#{id}")
      assert html_response(conn, 200) =~ "Language #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/languages", language: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Language"
    end
  end

  describe "edit language" do
    setup [:create_language]

    test "renders form for editing chosen language", %{conn: conn, language: language} do
      conn = get(conn, ~p"/languages/#{language}/edit")
      assert html_response(conn, 200) =~ "Edit Language"
    end
  end

  describe "update language" do
    setup [:create_language]

    test "redirects when data is valid", %{conn: conn, language: language} do
      conn = put(conn, ~p"/languages/#{language}", language: @update_attrs)
      assert redirected_to(conn) == ~p"/languages/#{language}"

      conn = get(conn, ~p"/languages/#{language}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, language: language} do
      conn = put(conn, ~p"/languages/#{language}", language: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Language"
    end
  end

  describe "delete language" do
    setup [:create_language]

    test "deletes chosen language", %{conn: conn, language: language} do
      conn = delete(conn, ~p"/languages/#{language}")
      assert redirected_to(conn) == ~p"/languages"

      assert_error_sent 404, fn ->
        get(conn, ~p"/languages/#{language}")
      end
    end
  end

  defp create_language(_) do
    language = language_fixture()
    %{language: language}
  end
end
