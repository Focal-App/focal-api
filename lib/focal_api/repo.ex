defmodule FocalApi.Repo do
  use Ecto.Repo,
    otp_app: :focal_api,
    adapter: Ecto.Adapters.Postgres
end
