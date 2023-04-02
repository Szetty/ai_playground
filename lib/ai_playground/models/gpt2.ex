defmodule AIPlayground.Models.GPT2 do
  def init do
    {:ok, model_info} = Bumblebee.load_model({:hf, "gpt2"}, log_params_diff: false)
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "gpt2"})

    Bumblebee.Text.generation(model_info, tokenizer,
      min_new_tokens: 1,
      max_new_tokens: 17,
      compile: [batch_size: 1, sequence_length: 100],
      defn_options: [compiler: EXLA]
    )
  end

  def run(serving, text) do
    %{results: [%{text: generated_text}]} = Nx.Serving.run(serving, text)
    generated_text
  end
end
