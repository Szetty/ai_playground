defmodule AIPlaygroundWeb.ChatLive.Message.Form do
  use AIPlaygroundWeb, :live_component
  import AIPlaygroundWeb.CoreComponents
  alias AIPlayground.Chat

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_form(%{"message" => "Hello, please introduce yourself!"})
    }
  end

  def assign_form(socket, form \\ %{}) do
    assign(socket, form: form)
  end

  def handle_event("update", %{"message_form" => form}, socket) do
    {:noreply, socket |> assign_form(form)}
  end

  def handle_event("save", %{"message_form" => %{"message" => message}}, socket) do
    %{room_id: room_id} = socket.assigns

    Chat.create_message(room_id, %{content: message, sender: "User"})

    {:noreply, socket |> assign_form}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        :let={f}
        for={@form}
        as={:message_form}
        phx-submit="save"
        phx-change="update"
        phx-target={@myself}
      >
        <.input autocomplete="off" field={{f, :message}} />
        <:actions>
          <.button>send</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end
