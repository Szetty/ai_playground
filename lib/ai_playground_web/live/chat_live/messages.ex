defmodule AIPlaygroundWeb.ChatLive.Messages do
  use AIPlaygroundWeb, :html
  import AIPlaygroundWeb.CoreComponents

  def list_messages(assigns) do
    ~H"""
    <div id="messages" phx-update="stream" class="overflow-scroll" style="height: calc(88vh - 10rem)">
      <div
        :for={{dom_id, message} <- @messages}
        id={dom_id}
        class="mt-2 hover:bg-gray-100 messages"
        data-toggle={JS.toggle(to: "#message-#{message.id}-buttons")}
      >
        <.message_details message={message} />
      </div>
    </div>
    """
  end

  def message_details(assigns) do
    ~H"""
    <.message_meta message={@message} />
    <.message_content message={@message} />
    """
  end

  def message_meta(assigns) do
    ~H"""
    <dl class="-my-4 divide-y divide-zinc-100">
      <div class="flex gap-4 py-4 sm:gap-2">
        <.user_icon />
        <dt class="w-1/8 flex-none text-[0.9rem] leading-8 text-zinc-500" style="font-weight: 900">
          <%= @message.sender %>
          <span style="font-weight: 300">
            [<%= @message.inserted_at
            |> DateTime.from_unix!()
            |> DateTime.to_string()
            |> String.replace("Z", " UTC") %>]
          </span>
        </dt>
      </div>
    </dl>
    """
  end

  def message_content(assigns) do
    ~H"""
    <dl class="-my-4 divide-y divide-zinc-100">
      <div class="flex gap-4 py-4 sm:gap-2">
        <dd class="text-sm leading-10 text-zinc-700" style="margin-left: 3%;margin-top: -1%;">
          <%= @message.content %>
        </dd>
      </div>
    </dl>
    """
  end
end
