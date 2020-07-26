defmodule Examroom.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Examroom.Repo,
      # Start the Telemetry supervisor
      ExamroomWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Examroom.PubSub},
      # Start the Endpoint (http/https)
      ExamroomWeb.Endpoint,
      # Start a worker by calling: Examroom.Worker.start_link(arg)
      # {Examroom.Worker, arg}
      ExamroomWeb.Presence,
      {Registry, keys: :unique, name: ExamroomWeb.RoomRegistry},
      {ExamroomWeb.RoomChannelSupervisor, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Examroom.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExamroomWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
