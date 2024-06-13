defmodule Chat.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :languages, references(:languages, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:rooms, [:languages])
  end
end
