defmodule ExamroomWeb.RoomChannelSupervisor do
  use DynamicSupervisor
  alias ExamroomWeb.RoomGenServer

  def start_link([]) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_child(roomId) do
    child_spec = {RoomGenServer, roomId}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
