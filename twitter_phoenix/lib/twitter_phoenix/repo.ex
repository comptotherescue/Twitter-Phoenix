defmodule TwitterPhoenix.Repo do
  use Ecto.Repo,
    otp_app: :twitter_phoenix,
    adapter: Ecto.Adapters.Postgres
end
