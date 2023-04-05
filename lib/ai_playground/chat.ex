defmodule AIPlayground.Chat do
  @moduledoc """
  The Chat context.
  """

  alias AIPlayground.Storage
  alias AIPlayground.Chat.Message
  alias AIPlaygroundWeb.Endpoint
  alias AIPlayground.ChatGPT

  def create_room do
    room_id = :crypto.strong_rand_bytes(16) |> Base.url_encode64()
    messages = []
    Storage.put_room(room_id, messages)
    room_id
  end

  def get_room_messages(room_id) do
    Storage.get_room(room_id)
  end

  def create_message(room_id, attrs \\ %{}) do
    message = Message.prepare_message(attrs)
    messages = Storage.get_room(room_id)
    new_messages = messages ++ [message]
    Storage.put_room(room_id, new_messages)

    publish_message_created(message, room_id)

    if message.sender == "User" do
      ChatGPT.create_chat_completion(new_messages, fn response ->
        create_message(room_id, %{content: response, sender: "GPT3.5"})
      end)
    end
  end

  def publish_message_created(%Message{} = message, room_id) do
    Endpoint.broadcast("room:#{room_id}", "new_message", %{message: message})
  end
end
