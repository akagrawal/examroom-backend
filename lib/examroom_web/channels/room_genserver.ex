defmodule ExamroomWeb.RoomGenServer do
  use GenServer
  require Logger

  defstruct(test_state: :idle, user_list: [], readiness: %{}, room_id: nil, life_span: nil)
  # APIs
  def start_link(room_id) do
    GenServer.start_link(__MODULE__, [room_id], name: {:global, room_id})
  end

  def add_user(user_name, room_id) do
    GenServer.call({:global, room_id}, {:add_user, user_name}, 10000)
  end

  def get_user_list(room_id) do
    GenServer.call({:global, room_id}, :get_user_list)
  end

  def get_ready_user_list(room_id) do
    GenServer.call({:global, room_id}, :get_ready_user_list)
  end

  def ready_user(user_name, room_id) do
    GenServer.cast({:global, room_id}, {"ready", user_name})
  end

  # gen_server callbacks
  def init([room_id]) do
    Logger.info("GenServer init #{inspect(room_id)}")
    room_state = ExamroomWeb.RoomGenServer.__struct__()
    {:ok, %{room_state | room_id: room_id, life_span: 10}}
  end

  def handle_call({:add_user, user_name}, _from, state) do
    Logger.info("GenServer add user #{inspect(user_name)}")
    prev_user_list = state.user_list -- [user_name]
    updated_user_list = prev_user_list ++ [user_name]

    new_state = %{
      state
      | user_list: updated_user_list,
        readiness: Map.put(state.readiness, user_name, false)
    }

    {:reply, :ok, new_state}
  end

  def handle_call(:get_user_list, _from, state) do
    Logger.info("fetching user list")
    {:reply, state.user_list, state}
  end

  def handle_call(:get_ready_user_list, _from, state) do
    Logger.info("fetching ready user list")

    readies =
      Enum.filter(state.readiness, fn {_user, ready} -> ready == true end)
      |> Enum.map(fn {user, _} -> user end)

    {:reply, readies, state}
  end

  def handle_cast({"ready", user_name}, state) do
    Logger.info("GenServer ready user #{inspect(user_name)}")
    new_state = %{state | readiness: Map.put(state.readiness, user_name, true)}
    _ref = Process.send_after(self(), :start_test, 0)
    {:noreply, new_state}
  end

  def handle_info(:start_test, state) do
    Logger.info("Start Test....#{inspect(state)}")

    readies =
      Enum.filter(state.readiness, fn {_user, ready} -> ready == true end)
      |> Enum.map(fn {user, _} -> user end)

    case state.user_list -- readies do
      [] ->
        ExamroomWeb.Endpoint.broadcast(Atom.to_string(state.room_id), "start_test", %{
          room_id: state.room_id,
          readies: readies,
          remaining_time: state.life_span
        })

        Process.send_after(self(), {"tick", state.life_span}, 1000)

      _ ->
        :ok
    end

    {:noreply, state}
  end

  def handle_info({"tick", 0}, state) do
    ExamroomWeb.Endpoint.broadcast(Atom.to_string(state.room_id), "end_test", %{
      room_id: state.room_id,
      remaining_time: 0

    })

    {:noreply, state}
  end

  def handle_info({"tick", remaining_time}, state) do
    ExamroomWeb.Endpoint.broadcast(Atom.to_string(state.room_id), "update_timer", %{
      room_id: state.room_id,
      remaining_time: remaining_time
    })
    Process.send_after(self(), {"tick", remaining_time - 1}, 1000)
    {:noreply, state}
  end
end
