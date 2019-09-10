use Mix.Config

# Configure your database
config :focal_api, FocalApi.Repo,
  username: "postgres",
  password: "postgres",
  database: "focal_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :focal_api, FocalApiWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
