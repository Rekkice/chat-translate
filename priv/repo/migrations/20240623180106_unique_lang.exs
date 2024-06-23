defmodule Chat.Repo.Migrations.UniqueLang do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      remove :content
      add :spanish_content, :text
      add :english_content, :text
    end
  end
end
