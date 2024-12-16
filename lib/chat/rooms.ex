defmodule Chat.Rooms do
  @moduledoc """
  The Rooms context.
  """

  import Ecto.Query, warn: false
  alias Chat.Messages.Message
  # alias Chat.Lang.Language
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
    # |> Repo.preload([:languages, :messages])
    |> Repo.preload([:messages])
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
  def get_room!(id), do: Repo.get!(Room, id) |> Repo.preload([:messages])

  def get_room_by_url_id!(id),
    do: Repo.get_by!(Room, url_id: id) |> Repo.preload([:messages])

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room({lang1, lang2}) do
    %Room{}
    |> Room.changeset(%{lang1: lang1, lang2: lang2, url_id: FriendlyID.generate(2)})
    |> Repo.insert()

    # %Language{name: "Español", room_id: room.id}
    # |> Language.changeset(%{})
    # |> Repo.insert!()

    # %Language{name: "Inglés", room_id: room.id}
    # |> Language.changeset(%{})
    # |> Repo.insert!()
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

  def send_message(%{lang1: lang1, lang2: lang2} = attrs, content) do
    IO.inspect("Sending message:")
    IO.inspect(content)
    IO.inspect("attrs:")
    IO.inspect(attrs)

    Chat.RateLimiters.LeakyBucket.make_request(
      {Chat.Translation, :translate, [content, {lang1, lang2}]},
      {__MODULE__, :handle_translation_result, [attrs]}
    )
  end

  def handle_translation_result(
        {:ok, %{"lang1" => lang1, "lang2" => lang2}},
        attrs
      ) do
    IO.inspect("Translation result:")
    IO.inspect(%{"lang1" => lang1, "lang2" => lang2})

    new_attrs = Map.merge(%{content_lang1: lang1, content_lang2: lang2}, attrs)

    %Message{}
    |> Message.changeset(new_attrs)
    |> Repo.insert()
    |> handle_insert_result()
    |> notify(attrs.room_id, :sent_message)

    send_confirmation(attrs.pid)
  end

  def handle_translation_result({:error, :bucket_full}, %{pid: pid}) do
    send(
      pid,
      {:put_alert,
       %{
         type: "error",
         message: "Too many messages are being processed right now, please try again later."
       }}
    )

    send_confirmation(pid)
  end

  def handle_translation_result({:error, reason}, %{pid: pid}) do
    IO.inspect("error:")
    IO.inspect(reason)

    send(
      pid,
      {:put_alert,
       %{
         type: "error",
         message: "There was an error translating the message, please try again later."
       }}
    )

    send_confirmation(pid)
  end

  def notify({:ok, %Message{} = message}, room_id, event) do
    PubSub.broadcast(Chat.PubSub, "room:#{room_id}", {event, message})
  end

  defp handle_insert_result({:ok, message}) do
    {:ok, message}
  end

  defp handle_insert_result({:error, changeset}) do
    IO.inspect("Failed to insert message:")
    IO.inspect(changeset)
    {:error, changeset}
  end

  def subscribe(id) do
    PubSub.subscribe(Chat.PubSub, "room:#{id}")
  end

  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  defp send_confirmation(pid), do: send(pid, :sent_confirmation)
end
