defmodule AIPlayground.Chat.Message do
  alias __MODULE__

  defstruct [
    :id,
    :content,
    # "User" or "ChatGPT"
    :sender,
    # Epoch time in seconds
    :inserted_at
  ]

  def prepare_message(attrs) do
    %Message{}
    |> Map.merge(attrs)
    |> add_id()
    |> add_timestamp()
  end

  defp add_id(%Message{} = message) do
    %{message | id: :crypto.strong_rand_bytes(16) |> Base.url_encode64()}
  end

  defp add_timestamp(%Message{} = message) do
    %{message | inserted_at: :os.system_time(:second)}
  end
end
