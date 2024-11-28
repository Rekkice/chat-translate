defmodule Chat.Repo.Migrations.FriendlyRoomIds do
  use Ecto.Migration

  def change do
    execute("DELETE FROM languages")
    execute("DELETE FROM messages")
    execute("DELETE FROM rooms")

    alter table(:rooms) do
      add :url_id, :string
    end

    create unique_index(:rooms, [:url_id])
  end
end
