defmodule FocalApi.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :event_name, :string
      add :shoot_date, :utc_datetime
      add :uuid, :uuid
      add :client_id, references(:clients, on_delete: :delete_all)
      add :package_id, references(:packages, on_delete: :delete_all)

      timestamps()
    end

  end

  def down do
    drop_if_exists table("events")
  end
end
