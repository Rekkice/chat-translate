defmodule Chat.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Jason.Encoder, except: [:__meta__, :room, :language]}

  schema "messages" do
    field :spanish_content, :string
    field :english_content, :string
    field :username, :string

    belongs_to :room, Chat.Rooms.Room
    belongs_to :language, Chat.Lang.Language

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:english_content, :spanish_content, :username, :room_id, :language_id])
    |> validate_required([:english_content, :spanish_content, :room_id])
    |> validate_length(:username, max: 24)
    |> validate_length(:english_content, max: 350) # limit client-side to 300
    |> validate_length(:spanish_content, max: 350) # limit client-side to 300
    |> unique_constraint(:room_id, name: :messages_room_id_language_id_index)
  end
end
