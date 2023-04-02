defmodule AIPlayground.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    IO.puts("Init")
    AIPlayground.init()

    spawn(fn ->
      if AIPlayground.all_models_working? do
        IO.puts("All models working as expected")
      end
    end)

    children = [
      # Start the Telemetry supervisor
      AIPlaygroundWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: AIPlayground.PubSub},
      # Start the Endpoint (http/https)
      AIPlaygroundWeb.Endpoint
      # Start a worker by calling: AIPlayground.Worker.start_link(arg)
      # {AIPlayground.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AIPlayground.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AIPlaygroundWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
