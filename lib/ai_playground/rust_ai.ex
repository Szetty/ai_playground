defmodule AIPlayground.RustAI do
  @rustler_opts [otp_app: :ai_playground, crate: :rust_ai]
  use Rustler, @rustler_opts

  def compile, do: Rustler.Compiler.compile_crate(__MODULE__, @rustler_opts)

  def init(), do: error()
  def translate_en_to_ro(_context, _string), do: error()
  def summarize(_context, _string), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
