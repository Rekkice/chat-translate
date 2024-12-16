defmodule ChatWeb.UserCache do
  @table :user_cache
  @metrics_table :metrics_cache

  def set_username(user_id, room_id, username),
    do: Cachex.put(@table, {user_id, room_id}, username)

  def get_username(user_id, room_id),
    do: Cachex.get(@table, {user_id, room_id})

  def get_metrics() do
    Cachex.fetch(@metrics_table, :room_count,
      fn ->
      {
        :commit,
        %{rooms: Chat.Repo.aggregate(Chat.Rooms.Room, :count, :id), messages: Chat.Repo.aggregate(Chat.Messages.Message, :count, :id)}, 
        expire: :timer.seconds(60)
      }
      end)
  end
end
