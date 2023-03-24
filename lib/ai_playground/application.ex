defmodule AiPlayground.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AiPlaygroundWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: AiPlayground.PubSub},
      # Start the Endpoint (http/https)
      AiPlaygroundWeb.Endpoint
      # Start a worker by calling: AiPlayground.Worker.start_link(arg)
      # {AiPlayground.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AiPlayground.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AiPlaygroundWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
