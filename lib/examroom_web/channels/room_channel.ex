defmodule ExamroomWeb.RoomChannel do
  use(ExamroomWeb, :channel)
  alias Examroom.Utils.AuthUtils
  require Logger
  @impl true
  def join("room:exam", user_details, socket) do
    case AuthUtils.user_registered?(user_details) do
      true ->
        Logger.info("#{inspect(user_details)}")
        {:ok, socket}
      false ->
        {:error, %{reason: "unauthorized"}}
      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

end
