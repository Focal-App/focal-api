defmodule FocalApi.Repo.Migrations.CreatePackages do
  use Ecto.Migration

  def change do
    create table(:packages) do
      add :package_name, :string
      add :uuid, :uuid
      add :client_id, references(:clients)

      timestamps()
    end

  end

  def down do
    drop_if_exists table("packages")
  end
end
