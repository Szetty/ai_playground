defmodule AIPlayground.ChatGPT do
  alias AIPlayground.Chat.Message
  require Logger

  def create_chat_completion(messages, callback_fn) do
    spawn(fn ->
      messages
      |> transform_to_open_ai_chat_messages()
      |> call_api()
      |> callback_fn.()
    end)
  end

  defp call_api(messages) do
    messages
    |> ExOpenAI.Chat.create_chat_completion("gpt-3.5-turbo")
    |> case do
      {:ok,
       %ExOpenAI.Components.CreateChatCompletionResponse{
         choices: [
           %{finish_reason: finish_reason, message: %{role: "assistant", content: content}}
         ]
       }} ->
        case finish_reason do
          "stop" ->
            content

          "length" ->
            content <>
              """
              Sorry, this is all because of the maximum tokens you provided!
              """

          other_finish_reason ->
            Logger.error("Unacceptable finish reason", response: inspect(other_finish_reason))
            "Something went wrong, sorry..."
        end

      response ->
        Logger.error("Unacceptable response", response: inspect(response))
        "Something went wrong, sorry..."
    end
  end

  defp transform_to_open_ai_chat_messages(messages) do
    messages
    |> Enum.map(fn %Message{content: content, sender: sender} ->
      role =
        case sender do
          "User" ->
            "user"

          "GPT3.5" ->
            "assistant"
        end

      %{role: role, content: content}
    end)
  end
end
