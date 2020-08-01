defmodule ExamroomWeb.ReceptionChannel do
  use ExamroomWeb, :channel
  alias Examroom.Utils.UserUtility
  require Logger

  @impl true
  def join("reception", _user_details, socket) do
    Logger.info("joining reception...")
    {:ok, socket}
  end

  # def handle_in("login", %{"username" => username, "password" => password}, socket) do
  def handle_in("login", user_details, socket) do
    Logger.info("trying to login... #{inspect(socket)}")
    Logger.info("trying to login... #{inspect(user_details)}")
    %{"username" => username, "password" => password} = user_details

    {response, socket} =
      case UserUtility.get_user(username) do
        [userdata] ->
          cond do
            userdata.password == password ->
              new_socket = assign(socket, :user, username)
              {{:ok, %{msg: "user logged in successfully", username: username}}, new_socket}

            true ->
              {{:error, %{msg: "wrong password"}}, socket}
          end

        [] ->
          {{:error, %{msg: "unauthorized user"}}, socket}
      end

    {:reply, response, socket}
  end

  def handle_in("register", user_details, socket) do
    Logger.info("trying to register... #{inspect(socket)}")
    response = UserUtility.register_user(user_details)
    Logger.info("#{inspect(response)}")
    {:reply, response, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:reception).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
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
