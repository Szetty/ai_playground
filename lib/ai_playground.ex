defmodule AIPlayground do
  @moduledoc """
  AIPlayground keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def init() do
    {:ok, rust_ai_context} = AIPlayground.RustAI.init()
    save_rust_ai_context(rust_ai_context)
  end

  def translate_en_to_ro(text) do
    {:ok, result} = AIPlayground.RustAI.translate_en_to_ro(get_rust_ai_context(), text)
    result
  end

  defp get_rust_ai_context do
    Application.get_env(:ai_playground, :rust_ai_context)
  end

  defp save_rust_ai_context(rust_ai_context) do
    Application.put_env(:ai_playground, :rust_ai_context, rust_ai_context)
  end
end
