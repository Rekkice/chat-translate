defmodule Chat.Application do
  alias Chat.RateLimiter
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {NodeJS.Supervisor, [path: LiveSvelte.SSR.NodeJS.server_path(), pool_size: 4]},
      ChatWeb.Telemetry,
      Chat.Repo,
      {DNSCluster, query: Application.get_env(:chat, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Chat.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Chat.Finch},
      # Start a worker by calling: Chat.Worker.start_link(arg)
      # {Chat.Worker, arg},
      # Start to serve requests, typically the last entry
      ChatWeb.Endpoint,
      {Task.Supervisor, name: RateLimiter.TaskSupervisor},
      {RateLimiter.get_rate_limiter(),
       %{
         timeframe_max_requests: RateLimiter.get_requests_per_timeframe(),
         timeframe_units: RateLimiter.get_timeframe_unit(),
         timeframe: RateLimiter.get_timeframe(),
         bucket_size: RateLimiter.get_bucket_size()
       }},
      ChatWeb.OgImage.Cache,
      {Cachex, [:user_cache]},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
