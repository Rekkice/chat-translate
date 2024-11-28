defmodule Chat.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Jason.Encoder, except: [:__meta__, :room, :language]}

  schema "messages" do
    field :content_lang1, :string
    field :content_lang2, :string
    field :username, :string

    belongs_to :room, Chat.Rooms.Room
    belongs_to :language, Chat.Lang.Language

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content_lang1, :content_lang2, :username, :room_id, :language_id])
    |> validate_required([:content_lang1, :content_lang2, :room_id])
    |> validate_length(:username, max: 24)
    |> validate_length(:content_lang1, max: 350) # limit client-side to 300
    |> validate_length(:content_lang2, max: 350) # limit client-side to 300
    |> unique_constraint(:room_id, name: :messages_room_id_language_id_index)
  end
end
