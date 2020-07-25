defmodule ExamroomWeb.RoomChannel do
use ExamroomWeb, :channel
  # alias Examroom.Utils.UserUtility
  require Logger

  @impl true
  def join(roomId, user_details, socket) do
    Logger.info("joining room #{inspect(user_details)} #{inspect(roomId)}" )
    {:ok, socket}
  end

  @impl true
  @spec terminate(any, any) :: {:ok, any}
  def terminate(reason, socket) do
    Logger.info("#{inspect(reason)}")
    Logger.info("#{inspect(socket)}")
    {:ok, socket}
  end
end
