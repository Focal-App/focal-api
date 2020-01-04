defmodule FocalApi.Repo.Migrations.UpdateUser do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :google_refresh_token, :string
      add :google_access_token, :string
      add :google_id, :string
    end
  end
end
