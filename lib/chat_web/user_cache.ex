defmodule ChatWeb.UserCache do
  @table :user_cache

  def set_username(user_id, room_id, username),
    do: Cachex.put(@table, {user_id, room_id}, username)

  def get_username(user_id, room_id),
    do: Cachex.get(@table, {user_id, room_id})
end
