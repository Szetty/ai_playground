defmodule AIPlaygroundWeb.ChatLive do
  use AIPlaygroundWeb, :live_view
  alias AIPlaygroundWeb.ChatLive.{Message, Messages}
  alias AIPlayground.Chat
  alias AIPlaygroundWeb.Endpoint

  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign_room()
      |> assign_room_messages()
    }
  end

  defp assign_room(socket) do
    room_id = Chat.create_room()
    if connected?(socket), do: Endpoint.subscribe("room:#{room_id}")
    assign(socket, :room_id, room_id)
  end

  defp assign_room_messages(%{assigns: %{room_id: room_id}} = socket) do
    stream(socket, :messages, Chat.get_room_messages(room_id))
  end

  def handle_info(%{event: "new_message", payload: %{message: message}}, socket) do
    {
      :noreply,
      socket
      |> stream_insert(:messages, message)
    }
  end

  def show_messages(assigns) do
    ~H"""
    <div id={"room-#{@room_id}"}>
      <Messages.list_messages messages={@messages} />
      <.live_component module={Message.Form} room_id={@room_id} id={"room-#{@room_id}-message-form"} />
    </div>
    """
  end
end
