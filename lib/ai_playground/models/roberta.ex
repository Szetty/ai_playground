defmodule AIPlayground.Models.RoBERTa do
  def init do
    {:ok, model_info} =
      Bumblebee.load_model({:hf, "finiteautomata/bertweet-base-emotion-analysis"},
        log_params_diff: false
      )

    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "vinai/bertweet-base"})

    Bumblebee.Text.text_classification(model_info, tokenizer,
      compile: [batch_size: 1, sequence_length: 100],
      defn_options: [compiler: EXLA]
    )
  end

  def run(serving, text) do
    %{predictions: predictions} = Nx.Serving.run(serving, text)
    predictions
  end
end
