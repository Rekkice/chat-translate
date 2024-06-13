defmodule ChatWeb.RoomHTML do
  use ChatWeb, :html

  embed_templates "room_html/*"

  @doc """
  Renders a room form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def room_form(assigns)
end
