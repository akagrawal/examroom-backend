defmodule ExamroomWeb.RoomChannel do
use ExamroomWeb, :channel
   alias ExamroomWeb.RoomChannelSupervisor
   alias ExamroomWeb.RoomGenServer
  require Logger

  @impl true
  @spec join(any, nil | keyword | map, any) :: {:ok, any}
  def join(room_id_string, user_details, socket) do
    room_id = String.to_atom(room_id_string)
    #check if user is already in a room, if yes, error else, generate room_id
    Logger.info("joining room #{inspect(user_details)} #{inspect(room_id)}")
    request = user_details["request"]
    user_name = user_details["username"]
    response =
      case request do
        "create" ->
          # start a gen_server
          case RoomChannelSupervisor.add_child(room_id) do
            {:ok, _Pid} ->
              RoomGenServer.add_user(user_name, room_id)
              "room created successfully"
            {:error, {:already_started, _Pid}} ->
              "internal_error"
            end
        "join" ->
          case :global.whereis_name(room_id) do
            :undefined ->
             "room does not exist"
            _Pid ->
              :ok = RoomGenServer.add_user(user_name, room_id)
              "user joined room successfully"
          end
            # check if room exists, if yes then send msg to gen_server else return error
            # Logger.info("joining room #{inspect(res1)} #{inspect(res2)}")
      end
    {:ok, response, socket}
  end

  @impl true
  @spec terminate(any, any) :: {:ok, any}
  def terminate(reason, socket) do
    Logger.info("#{inspect(reason)}")
    Logger.info("#{inspect(socket)}")
    {:ok, socket}
  end
end
