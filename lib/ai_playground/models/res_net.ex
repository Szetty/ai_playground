defmodule AIPlayground.Models.ResNet do
  def init do
    {:ok, model_info} = Bumblebee.load_model({:hf, "microsoft/resnet-50"}, log_params_diff: false)

    {:ok, featurizer} = Bumblebee.load_featurizer({:hf, "microsoft/resnet-50"})

    Bumblebee.Vision.image_classification(model_info, featurizer,
      compile: [batch_size: 1],
      defn_options: [compiler: EXLA]
    )
  end

  def run(serving, %{data: data, height: height, width: width} = image) do
    input =
      data
      |> Nx.from_binary(:u8)
      |> Nx.reshape({height, width, 3})

    %{predictions: predictions} = Nx.Serving.run(serving, input)
    predictions
  end
end
