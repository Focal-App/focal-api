defmodule FocalApi.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :uuid, :uuid
      add :category, :text
      add :step, :text
      add :is_completed, :boolean, default: false, null: false
      add :event_id, references(:events, on_delete: :nothing)
      add :client_id, references(:clients, on_delete: :nothing)

      timestamps()
    end

    create index(:tasks, [:event_id])
    create index(:tasks, [:client_id])
  end
end
