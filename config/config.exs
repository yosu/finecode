# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :finecode, FinecodeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wvhhRCD2TuSQHO1PQy0V30paHYx9sMsKXKHrqneCD8giuvXVbFRHteEsfCJzAXbV",
  render_errors: [view: FinecodeWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Finecode.PubSub,
  live_view: [signing_salt: "ODI7VfLu"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Use Timezone database
# https://github.com/lau/tzdata
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Base tag URI for Atom feed
config :finecode, :tag_uri, "tag:fine-code.com,2020"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
