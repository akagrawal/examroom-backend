defmodule ExamroomWeb.RoomChannel do
use ExamroomWeb, :channel
  alias Examroom.Utils.AuthUtils
  alias Examroom.Utils.UserUtility
  require Logger

  @impl true
  def join("room:lobby", _user_details, socket) do
    {:ok, socket}
  end

  def join("room:exam", user_details, socket) do
    Logger.info("#{inspect(socket)}")
    case AuthUtils.user_registered?(user_details) do
      true ->
        Logger.info("#{inspect(user_details)}")
        {:ok, socket}
      false ->
        {:error, %{msg: "unauthorized"}}
      {:error, reason} ->
        {:error, %{msg: reason}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("login",%{"userid" => userid, "password" => password}, socket) do
    Logger.info("#{inspect(socket)}")
    response =
      case UserUtility.get_user(userid) do
        [userdata] ->
          cond do
            userdata.password == password ->
              {:ok, %{msg: "user logged in successfully"}}
            true ->
              {:error, %{msg: "wrong password"}}
          end
        [] ->
          {:error, %{msg: "unauthorized user"}}
      end
    {:reply, response, socket}
  end

  def handle_in("register", user_details, socket) do
    response = UserUtility.register_user(user_details)
    Logger.info("#{inspect(response)}")
    {:reply, response, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

end
