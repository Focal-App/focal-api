# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :focal_api,
  ecto_repos: [FocalApi.Repo],
  client_host: System.get_env("CLIENT_HOST")

# Configures the endpoint
config :focal_api, FocalApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hSbFt51zzCLi5Cs0THUL0+i8IIKGt3rnXhAERkkjQlc/bN9iwXBmPDkFhw5YRjO5",
  render_errors: [view: FocalApiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: FocalApi.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :tesla, adapter: Tesla.Adapter.Hackney

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Google OAuth:
config :ueberauth, Ueberauth,
  providers: [
    google:
      {Ueberauth.Strategy.Google,
       [
         access_type: "offline",
         default_scope:
           "email profile https://www.googleapis.com/auth/gmail.compose https://www.googleapis.com/auth/gmail.readonly https://mail.google.com/",
         prompt: "select_account"
       ]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
