defmodule  ExamroomWeb.RoomGenServer do
  use GenServer
  require Logger

  defstruct( user_list: [])
  # APIs
  def start_link(room_id) do
    GenServer.start_link(__MODULE__, [room_id], [name: room_id])
  end

  def add_user(user_name, room_id) do
    GenServer.call({:global, room_id}, {:add_user, user_name}, 10000)
  end

  def get_user_list(room_id) do
    GenServer.call({:global, room_id}, :get_user_list)
  end

  # gen_server callbacks
  def init([room_id]) do
    Logger.info("GenServer init #{inspect(room_id)}")
    room_state = ExamroomWeb.RoomGenServer.__struct__()
    {:ok, room_state}
  end

  def handle_call({:add_user, user_name}, _from, state) do
    Logger.info("GenServer add user #{inspect(user_name)}")
    prev_user_list = state.user_list -- [user_name]
    updated_user_list = prev_user_list ++ [user_name]
    new_state = %{state | user_list: updated_user_list}
    {:reply, :ok, new_state}
  end

  def handle_call(:get_user_list, _from, state) do
    Logger.info("fetching user list")
    {:reply, state.user_list, state}
  end

# %{room_state | user_list: []}
end
