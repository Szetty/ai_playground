defmodule AIPlayground.Models.StableDiffusion do
  def init(num_steps \\ 20) do
    repository_id = "CompVis/stable-diffusion-v1-4"
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "openai/clip-vit-large-patch14"})

    {:ok, clip} =
      Bumblebee.load_model({:hf, repository_id, subdir: "text_encoder"},
        log_params_diff: false
      )

    {:ok, unet} =
      Bumblebee.load_model({:hf, repository_id, subdir: "unet"},
        params_filename: "diffusion_pytorch_model.bin",
        log_params_diff: false
      )

    {:ok, vae} =
      Bumblebee.load_model({:hf, repository_id, subdir: "vae"},
        architecture: :decoder,
        params_filename: "diffusion_pytorch_model.bin",
        log_params_diff: false
      )

    {:ok, scheduler} = Bumblebee.load_scheduler({:hf, repository_id, subdir: "scheduler"})

    {:ok, featurizer} =
      Bumblebee.load_featurizer({:hf, repository_id, subdir: "feature_extractor"})

    {:ok, safety_checker} =
      Bumblebee.load_model({:hf, repository_id, subdir: "safety_checker"},
        log_params_diff: false
      )

    Bumblebee.Diffusion.StableDiffusion.text_to_image(clip, unet, vae, tokenizer, scheduler,
      num_steps: num_steps,
      num_images_per_prompt: 2,
      safety_checker: safety_checker,
      safety_checker_featurizer: featurizer,
      compile: [batch_size: 1, sequence_length: 50],
      defn_options: [compiler: EXLA]
    )
  end

  def run(serving, text) do
    %{results: results} = Nx.Serving.run(serving, text)
    results
  end
end
