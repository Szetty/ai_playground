defmodule AIPlayground.RustAI do
  use Rustler, otp_app: :ai_playground, crate: :rust_ai

  def init(), do: error()
  def translate_en_to_ro(_context, _string), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
