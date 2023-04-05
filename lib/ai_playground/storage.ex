defmodule AIPlayground.Storage do
  @rooms_table_name :rooms

  def init do
    ETS.KeyValueSet.new!(name: @rooms_table_name, protection: :public)
    :ok
  end

  def put_room(room_id, room_value) do
    :rooms
    |> ETS.KeyValueSet.wrap_existing!()
    |> ETS.KeyValueSet.put!(room_id, room_value)
  end

  def get_room(room_id) do
    :rooms
    |> ETS.KeyValueSet.wrap_existing!()
    |> ETS.KeyValueSet.get!(room_id)
  end

  def put_message_in_room(room_id, message) do
    room_id
    |> get_room()
    |> Kernel.++([message])
    |> then(&put_room(room_id, &1))

    message
  end
end
