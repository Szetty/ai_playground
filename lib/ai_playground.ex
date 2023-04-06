defmodule AIPlayground do
  @moduledoc """
  AIPlayground keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias AIPlayground.Models.{GPT2, RoBERTa, BERTNER, ResNet, StableDiffusion}
  alias AIPlayground.RustAI
  alias AIPlayground.Storage

  @models [
    GPT2,
    RoBERTa,
    BERTNER,
    ResNet,
    StableDiffusion
  ]

  @type scored_list :: [%{label: String.t(), score: float()}]

  @type entities_list :: [
          %{
            start: non_neg_integer(),
            end: non_neg_integer(),
            label: String.t(),
            phrase: String.t(),
            score: float()
          }
        ]

  def init() do
    init_storage()
    init_ai()
  end

  def init_storage() do
    Storage.init()
  end

  def init_ai() do
    init_rust_ai()

    @models
    |> Enum.each(fn model ->
      model.init()
      |> then(&save_model(model, &1))
    end)

    spawn(fn ->
      if AIPlayground.all_models_working?() do
        IO.puts("All models working as expected")
      end
    end)
  end

  @spec run_gpt2(String.t()) :: String.t()
  def run_gpt2(text), do: run_model(GPT2, text)

  @spec run_roberta(String.t()) :: scored_list()
  def run_roberta(text), do: run_model(RoBERTa, text)

  @spec run_bert_ner(String.t()) :: entities_list()
  def run_bert_ner(text), do: run_model(BERTNER, text)

  @spec run_res_net(%{data: binary(), height: non_neg_integer(), width: non_neg_integer()}) ::
          scored_list()
  def run_res_net(image), do: run_model(ResNet, image)

  @spec run_stable_diffusion(String.t()) :: any()
  def run_stable_diffusion(text), do: run_model(StableDiffusion, text)

  @spec translate_en_to_ro(String.t()) :: String.t()
  def translate_en_to_ro(text) do
    {:ok, result} = AIPlayground.RustAI.translate_en_to_ro(get_model(RustAI), text)
    result
  end

  @spec summarize(String.t()) :: String.t()
  def summarize(text) do
    {:ok, result} = AIPlayground.RustAI.summarize(get_model(RustAI), text)
    result
  end

  def all_models_working? do
    "Yesterday, I was reading a book and I was thinking, \"What's going on here?\" I was thinking, \"What" =
      run_gpt2("Yesterday, I was reading a book and")

    [
      %{label: "surprise", score: surprise_score},
      %{label: "others", score: _},
      %{label: "joy", score: _},
      %{label: "anger", score: _},
      %{label: "fear", score: _}
    ] = AIPlayground.run_roberta("Oh wow, I didn't know that!")

    if surprise_score - 0.98 >= 0.01 do
      raise "RoBERTa not working properly"
    end

    [
      %{
        start: 0,
        end: 12,
        label: "PER",
        phrase: "Rachel Green"
      },
      %{
        start: 22,
        end: 34,
        label: "ORG",
        phrase: "Ralph Lauren"
      },
      %{
        start: 38,
        end: 51,
        label: "LOC",
        phrase: "New York City"
      },
      %{
        start: 66,
        end: 73,
        label: "MISC",
        phrase: "Friends"
      }
    ] = run_bert_ner("Rachel Green works at Ralph Lauren in New York City in the sitcom Friends.")

    " salutări" = translate_en_to_ro("hello")

    " hello, i'm katie mccartney and i love you. thank you so much for stopping by my page. catiema: i am so happy that you stopped by my blog. thanks for visiting." =
      summarize(
        "Hello, i'm katie mccartney.. Hello, my name is catiema and i love you. Thank you for stopping by my page. thank you for visiting my page and thank you so much for your time."
      )

    true
  end

  defp init_rust_ai do
    {:ok, rust_ai_context} = RustAI.init()
    save_model(RustAI, rust_ai_context)
  end

  defp save_model(name, model) do
    Application.put_env(:ai_playground, name, model)
  end

  defp run_model(model, input) do
    model.run(get_model(model), input)
  end

  defp get_model(name) do
    Application.get_env(:ai_playground, name)
  end
end
