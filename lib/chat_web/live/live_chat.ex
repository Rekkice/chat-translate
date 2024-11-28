defmodule ChatWeb.ChatLive do
  use ChatWeb, :live_view
  alias Chat.Rooms

  def render(assigns) do
    ~H"""
    <.svelte
      name="Chat"
      props={
        %{
          # languages: @languages,
          initialMessages: @init_messages,
          lang1: @lang1,
          lang2: @lang2
        }
      }
      socket={@socket}
    />
    """
  end

  def mount(%{"id" => id}, _session, socket) do
    room = Rooms.get_room_by_url_id!(id)
    Rooms.subscribe(room.id)

    {:ok,
     assign(socket,
       room: room,
       init_messages: room.messages,
       lang1: room.lang1,
       lang2: room.lang2
     )}
  end

  def handle_event("send_message", %{"content" => content, "username" => username}, socket) do
    assigns = socket |> Map.get(:assigns)

    room =
      assigns
      |> Map.get(:room)

    Rooms.send_message(%{room_id: room.id, username: username, lang1: room.lang1, lang2: room.lang2}, content)

    {:noreply, socket}
  end

  def handle_event("put_flash", %{"type" => type, "message" => message}, socket) do
    {:noreply, put_flash(socket, String.to_atom(type), message)}
  end

  def handle_info({:put_flash, type, message}, socket) do
    {:noreply, put_flash(socket, type, message)}
  end

  def handle_info({:sent_message, message}, socket) do
    {:noreply, push_event(socket, "received_message", %{message: message})}
  end
end
