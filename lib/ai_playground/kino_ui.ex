defmodule AIPlayground.KinoUI do
  def text_to_text(title, text, model_runner) do
    build_ui_with_form_frame_separator(title, text, fn frame, %{text: text} ->
      Kino.Frame.render(frame, Kino.Markdown.new(model_runner.(text)))
    end)
  end

  def text_to_scored_list(title, text, model_runner) do
    build_ui_with_form_frame_separator(title, text, fn frame, %{text: text} ->
      model_runner.(text)
      |> Enum.map(&{&1.label, &1.score})
      |> Kino.Bumblebee.ScoredList.new()
      |> then(&Kino.Frame.render(frame, &1))
    end)
  end

  def text_to_highlighted_text(title, text, model_runner) do
    build_ui_with_form_frame_separator(title, text, fn frame, %{text: text} ->
      Kino.Frame.render(
        frame,
        Kino.Bumblebee.HighlightedText.new(text, model_runner.(text))
      )
    end)
  end

  def image_to_scored_list(title, model_runner) do
    form = form_with_image(title)

    frame =
      frame_on_form_listen(
        form,
        fn frame, %{image: image} ->
          model_runner.(image)
          |> Enum.map(&{&1.label, &1.score})
          |> Kino.Bumblebee.ScoredList.new()
          |> then(&Kino.Frame.render(frame, &1))
        end,
        & &1.data.image
      )

    [form, frame, separator()]
  end

  def text_to_image_layout(text, model_runner) do
    text_input = Kino.Input.textarea("Text", default: text)

    form = Kino.Control.form([text: text_input], submit: "Run")
    frame = Kino.Frame.new()

    form
    |> Kino.Control.stream()
    |> Kino.listen(fn %{data: %{text: text}} ->
      Kino.Frame.render(frame, Kino.Markdown.new("Running..."))
      results = model_runner.(text)

      for result <- results do
        Kino.Image.new(result.image)
      end
      |> Kino.Layout.grid(columns: 2)
      |> then(&Kino.Frame.render(frame, &1))
    end)

    Kino.Layout.grid([form, frame], boxed: true, gap: 16)
  end

  defp build_ui_with_form_frame_separator(title, text, output_renderer) do
    form = form_with_text(title, text)
    frame = frame_on_form_listen(form, output_renderer)

    [form, frame, separator()]
  end

  defp form_with_text(title, text) do
    text_input = Kino.Input.textarea(title, default: text)
    Kino.Control.form([text: text_input], submit: "Run")
  end

  defp form_with_image(title) do
    image_input = Kino.Input.image(title, size: {224, 224})
    Kino.Control.form([image: image_input], submit: "Run")
  end

  defp frame_on_form_listen(form, output_renderer, filter \\ fn _ -> true end) do
    frame = Kino.Frame.new()

    form
    |> Kino.Control.stream()
    |> Stream.filter(filter)
    |> Kino.listen(fn %{data: data} ->
      Kino.Frame.render(frame, Kino.Markdown.new("Running..."))
      output_renderer.(frame, data)
    end)

    frame
  end

  defp separator do
    Kino.HTML.new("<hr>")
  end

  def build_grid_layout(elements) do
    Kino.Layout.grid(
      elements,
      boxed: true,
      gap: 16
    )
  end
end
