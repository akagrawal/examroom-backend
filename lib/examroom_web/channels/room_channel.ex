defmodule ExamroomWeb.RoomChannel do
  use ExamroomWeb, :channel
  alias ExamroomWeb.RoomChannelSupervisor
  alias ExamroomWeb.RoomGenServer
  require Logger

  @impl true
  @spec join(any, nil | keyword | map, any) :: {:ok, any}
  def join(room_id_string, user_details, socket) do
    room_id = String.to_atom(room_id_string)
    # check if user is already in a room, if yes, error else, generate room_id
    Logger.info("joining room #{inspect(user_details)} #{inspect(room_id)}")
    request = user_details["request"]
    user_name = user_details["username"]

    case request do
      "create" ->
        # start a gen_server
        case RoomChannelSupervisor.add_child(room_id) do
          {:ok, _Pid} ->
            :ok = RoomGenServer.add_user(user_name, room_id)
            {:ok, %{msg: "room created successfully", user_list: [user_name], readies: []}, socket}

          {:error, {:already_started, _Pid}} ->
            {:error, %{msg: "internal_error"}}
        end

      "join" ->
        case :global.whereis_name(room_id) do
          :undefined ->
            {:error, %{msg: "room does not exist"}}

          _Pid ->
            :ok = RoomGenServer.add_user(user_name, room_id)
            # Give current state of room
            {:ok,
             %{
               msg: "user joined room successfully",
               user_list: RoomGenServer.get_user_list(room_id),
               readies: RoomGenServer.get_ready_user_list(room_id)
             }, socket}
        end

        # check if room exists, if yes then send msg to gen_server else return error
        # Logger.info("joining room #{inspect(res1)} #{inspect(res2)}")
    end
  end

  @impl true
  @spec handle_in(<<_::40, _::_*8>>, map, Phoenix.Socket.t()) :: {:noreply, Phoenix.Socket.t()}
  def handle_in("start_test", %{"body" => room_id}, socket) do
    Logger.info("start_test for #{inspect(room_id)}")
    # check if this user can start the test or not
    broadcast(socket, "start_test", %{roomid: room_id})
    {:noreply, socket}
  end

  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_in("new_user", %{"body" => user_name}, socket) do
    Logger.info("new user added #{inspect(user_name)}")
    broadcast(socket, "new_user", %{username: user_name})
    {:noreply, socket}
  end

  def handle_in("ready", %{"username" => user_name, "roomId" => room_id_string}, socket) do
    room_id = String.to_atom(room_id_string)
    Logger.info("user #{inspect(user_name)} in #{inspect(room_id)} is ready")
    RoomGenServer.ready_user(user_name, room_id)
    broadcast(socket, "ready_ack", %{user_name: user_name})
    {:noreply, socket}
  end

  @impl true
  @spec terminate(any, any) :: {:ok, any}
  def terminate(reason, socket) do
    Logger.info("#{inspect(reason)}")
    Logger.info("#{inspect(socket)}")
    {:ok, socket}
  end
end
