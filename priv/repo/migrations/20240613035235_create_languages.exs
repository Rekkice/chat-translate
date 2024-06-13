defmodule Chat.Repo.Migrations.CreateLanguages do
  use Ecto.Migration

  def change do
    create table(:languages) do
      add :name, :string
      add :room, references(:rooms, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:languages, [:room])
  end
end
