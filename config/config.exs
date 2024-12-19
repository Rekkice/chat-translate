# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :chat,
  ecto_repos: [Chat.Repo],
  generators: [timestamp_type: :utc_datetime]

config :chat, Chat.Rooms,
  # used to show as options in forms and to check if a language is valid
  languages: ["English", "Spanish", "Portuguese", "Chinese", "Japanese", "Russian"],
  default_languages: {"English", "Spanish"}

config :chat, Chat.Translation,
  model: "llama3-groq-70b-8192-tool-use-preview",
  api_url: "https://api.groq.com/openai/v1/chat/completions"

# Configures the endpoint
config :chat, ChatWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ChatWeb.ErrorHTML, json: ChatWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Chat.PubSub,
  live_view: [signing_salt: "zBwxTxQz"]

config :live_svelte, ssr_module: ChatWeb.SSR.Deno

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :chat, Chat.Mailer, adapter: Swoosh.Adapters.Local

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  chat: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures rate limiter for LLM API
# 30 requests per minute
# 1440 requests per day
# 40000 tokens per minute
config :chat, RateLimiter,
  rate_limiter: Chat.RateLimiters.LeakyBucket,
  timeframe_max_requests: 30,
  timeframe_units: :seconds,
  timeframe: 60,
  bucket_size: 5

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
