defmodule Chat.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Jason.Encoder, except: [:__meta__]}

  schema "rooms" do
    field :url_id, :string
    
    # has_many :languages, Chat.Lang.Language
    has_many :messages, Chat.Messages.Message

    field :lang1, :string
    field :lang2, :string

    timestamps(type: :utc_datetime)
  end

  defp validate_different_languages(changeset) do
    lang1 = get_field(changeset, :lang1)
    lang2 = get_field(changeset, :lang2)

    if lang1 == lang2 do
      add_error(changeset, :lang2, "Language 2 must be different from Language 1")
    else
      changeset
    end
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:lang1, :lang2, :url_id])
    |> validate_required([:lang1, :lang2, :url_id])
    |> validate_inclusion(:lang1, Application.get_env(:chat, Chat.Rooms)[:languages])
    |> validate_inclusion(:lang2, Application.get_env(:chat, Chat.Rooms)[:languages])
    |> validate_different_languages
  end
end
