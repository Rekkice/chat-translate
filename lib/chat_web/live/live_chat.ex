defmodule ChatWeb.ChatLive do
  use ChatWeb, :live_view
  use ChatWeb, :verified_routes
  alias Chat.Rooms

  def render(assigns) do
    ~H"""
    <.svelte
      name="Chat"
      props={
        %{
          username: @username,
          initialMessages: @init_messages,
          lang1: @lang1,
          lang2: @lang2
        }
      }
      socket={@socket}
    />
    """
  end

  def mount(%{"id" => room_id}, %{"id" => user_id}, socket) do
    room = Rooms.get_room_by_url_id!(room_id)
    # takes real room id
    Rooms.subscribe(room.id)

    username =
      case ChatWeb.UserCache.get_username(user_id, room_id) do
        {:ok, nil} -> ""
        {:ok, username} -> username
        _ -> ""
      end

    {:ok,
     assign(socket,
       room: room,
       init_messages: room.messages,
       lang1: room.lang1,
       lang2: room.lang2,
       page_title: room_id,
       og_description: "A #{room.lang1} and #{room.lang2} chat room with live translation.",
       og_image: ~p"/og/room/#{room_id}",
       username: username,
       user_id: user_id
     )}
  end

  def handle_event("set_username", %{"username" => username}, socket) do
    %{user_id: user_id, room: room} = socket |> Map.get(:assigns)
    ChatWeb.UserCache.set_username(user_id, room.url_id, username)

    {:noreply, socket}
  end

  def handle_event("send_message", %{"content" => content, "username" => username}, socket) do
    assigns = socket |> Map.get(:assigns)

    room =
      assigns
      |> Map.get(:room)

    Rooms.send_message(
      %{room_id: room.id, username: username, lang1: room.lang1, lang2: room.lang2, pid: self()},
      content
    )

    {:noreply, socket}
  end

  def handle_info({:put_alert, %{type: type, message: message}}, socket),
    do: {:noreply, push_event(socket, "received_alert", %{type: type, message: message})}

  def handle_info(:sent_confirmation, socket),
    do: {:noreply, push_event(socket, "sent_confirmation", %{})}

  def handle_info({:sent_message, message}, socket),
    do: {:noreply, push_event(socket, "received_message", %{message: message})}
end
