defmodule Chat.Repo.Migrations.RefactorLanguages do
  use Ecto.Migration

  def change do
    rename table(:messages), :spanish_content, to: :content_lang1
    rename table(:messages), :english_content, to: :content_lang2

    alter table(:rooms) do
      add :lang1, :string, null: false, default: "Spanish"
      add :lang2, :string, null: false, default: "English"
    end
  end
end
