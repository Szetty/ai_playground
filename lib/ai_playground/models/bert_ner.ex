defmodule AIPlayground.Models.BERTNER do
  def init do
    {:ok, model_info} = Bumblebee.load_model({:hf, "dslim/bert-base-NER"}, log_params_diff: false)

    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "bert-base-cased"})

    Bumblebee.Text.token_classification(model_info, tokenizer,
      aggregation: :same,
      compile: [batch_size: 1, sequence_length: 100],
      defn_options: [compiler: EXLA]
    )
  end

  def run(serving, text) do
    %{entities: entities} = Nx.Serving.run(serving, text)
    entities
  end
end
