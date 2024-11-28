# TODO unused, should refactor to use instead of lang1/lang2 fields later

defmodule Chat.Lang.Language do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Jason.Encoder, except: [:__meta__, :room]}

  schema "languages" do
    field :name, :string

    belongs_to :room, Chat.Rooms.Room

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(language, attrs) do
    language
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> cast_assoc(:room)
  end
end
