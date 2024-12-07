defmodule Chat.RoomsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chat.Rooms` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    {:ok, room} =
      attrs
      |> Enum.into(%{})
      |> Chat.Rooms.create_room()

    room
  end
end
