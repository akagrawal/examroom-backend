defmodule ExamroomWeb.UserSocket do
  require Logger
  use Phoenix.Socket
  ## Channels
  channel "reception", ExamroomWeb.ReceptionChannel
  channel "room*", ExamroomWeb.RoomChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  # dl;
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoeni[x.Token` documentation for examples in
  # performing token 'verification on connect.
  @impl true
  @spec connect(map, Phoenix.Socket.t(), any) :: {:ok, Phoenix.Socket.t()}
  def connect(%{"user" => user}, socket, _connect_info) do
    {:ok, assign(socket, :user, user)}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     ExamroomWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil

  @impl true
  def terminate(reason, socket) do
    Logger.info("#{inspect(reason)}")
    Logger.info("#{inspect(socket)}")
  end
end
