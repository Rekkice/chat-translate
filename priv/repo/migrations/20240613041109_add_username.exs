defmodule Chat.Repo.Migrations.AddUsername do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :username, :string, null: false
    end
  end
end
