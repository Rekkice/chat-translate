defmodule Chat.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Jason.Encoder, except: [:__meta__]}

  schema "rooms" do
    # has_many :languages, Chat.Lang.Language
    has_many :messages, Chat.Messages.Message

    field :lang1, :string
    field :lang2, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [])
    |> validate_required([])
  end
end
