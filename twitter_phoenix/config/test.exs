use Mix.Config

# Configure your database
config :twitter_phoenix, TwitterPhoenix.Repo,
  username: "postgres",
  password: "postgres",
  database: "twitter_phoenix_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :twitter_phoenix, TwitterPhoenixWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
