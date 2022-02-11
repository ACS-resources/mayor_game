defmodule MayorGame.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      MayorGame.Repo,
      # Start the Telemetry supervisor
      MayorGameWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MayorGame.PubSub},
      # Start the Endpoint (http/https)
      MayorGameWeb.Endpoint,

      # start mover process with initial value 15
      # oh this is how you can start multiple children
      # Start a worker by calling: MayorGame.CityCalculator.start_link(arg)

      Supervisor.child_spec({MayorGame.CityCalculator, 1}, id: :city_calculator),

      # mnesia cache for sessions?
      Pow.Store.Backend.MnesiaCache
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MayorGame.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MayorGameWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
