defmodule Chat.Rooms do
  @moduledoc """
  The Rooms context.
  """

  import Ecto.Query, warn: false
  alias Chat.Messages.Message
  alias Chat.Lang.Language
  alias Chat.Repo
  alias Phoenix.PubSub

  alias Chat.Rooms.Room

  @doc """
  Returns the list of rooms.

  ## Examples

      iex> list_rooms()
      [%Room{}, ...]

  """
  def list_rooms do
    Repo.all(Room)
    |> Repo.preload([:languages, :messages])
  end

  def list_rooms_nopl do
    Repo.all(Room)
  end

  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room!(id), do: Repo.get!(Room, id) |> Repo.preload([:languages, :messages])

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room() do
    Repo.transaction(fn ->
      room_changeset = Room.changeset(%Room{}, %{})
      {:ok, room} = Repo.insert(room_changeset)

      %Language{name: "Español", room_id: room.id}
      |> Language.changeset(%{})
      |> Repo.insert!()

      %Language{name: "Inglés", room_id: room.id}
      |> Language.changeset(%{})
      |> Repo.insert!()

      {:ok, room}
    end)
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  def send_message(attrs, content) do
    IO.inspect("Sending message:")
    IO.inspect(content)

    case Chat.Translation.translate(content) do
      {:ok, translation = %{"english" => english, "spanish" => spanish}} ->
        IO.inspect("Translation result:")
        IO.inspect(translation)

        new_attrs = Map.merge(%{english_content: english, spanish_content: spanish}, attrs)

        %Message{}
        |> Message.changeset(new_attrs)
        |> Repo.insert()
        |> handle_insert_result()
        |> notify(attrs.room_id, :sent_message)

      {:error, reason} ->
        IO.inspect(reason, label: "Translation error:")
    end
  end

  def notify({:ok, %Message{} = message}, room_id, event) do
    PubSub.broadcast(Chat.PubSub, "room:#{room_id}", {event, message})
  end

  defp handle_insert_result({:ok, message}) do
    IO.inspect("Message inserted successfully:")
    IO.inspect(message)
    {:ok, message}
  end

  defp handle_insert_result({:error, changeset}) do
    IO.inspect("Failed to insert message:")
    IO.inspect(changeset)
    {:error, changeset}
  end

  # def send_message(room_id, attrs) do
  #   %Message{}
  #   |> Message.changeset(Map.put(attrs, :room_id, room_id))
  #   |> Repo.insert()
  # end

  def subscribe(id) do
    PubSub.subscribe(Chat.PubSub, "room:#{id}")
  end

  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end
end
