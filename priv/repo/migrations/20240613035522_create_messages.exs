defmodule Chat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :string
      add :room, references(:rooms, on_delete: :delete_all)
      add :language, references(:languages, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:room])
    create index(:messages, [:language])
  end
end
