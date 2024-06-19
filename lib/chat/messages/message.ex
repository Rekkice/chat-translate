defmodule Chat.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Jason.Encoder, except: [:__meta__, :room, :language]}

  schema "messages" do
    field :content, :string
    field :username, :string

    belongs_to :room, Chat.Rooms.Room
    belongs_to :language, Chat.Lang.Language

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :username, :room_id, :language_id])
    |> validate_required([:content, :room_id])
    |> validate_length(:username, max: 24)
    |> validate_length(:content, max: 350) # limit client-side to 300
  end
end
