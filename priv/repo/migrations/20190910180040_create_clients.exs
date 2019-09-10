defmodule FocalApi.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :client_name, :string
      add :uuid, :uuid

      timestamps()
    end

  end

  def down do
    drop_if_exists table("clients")
  end
end
