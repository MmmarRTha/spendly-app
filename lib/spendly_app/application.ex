defmodule SpendlyApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SpendlyAppWeb.Telemetry,
      SpendlyApp.Repo,
      {DNSCluster, query: Application.get_env(:spendly_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SpendlyApp.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SpendlyApp.Finch},
      # Start a worker by calling: SpendlyApp.Worker.start_link(arg)
      # {SpendlyApp.Worker, arg},
      # Start to serve requests, typically the last entry
      SpendlyAppWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SpendlyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SpendlyAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
