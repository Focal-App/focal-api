defmodule FocalApi.Repo.Migrations.CreateWorkflows do
  use Ecto.Migration

  def change do
    create table(:workflows) do
      add :uuid, :uuid
      add :workflow_name, :string
      add :client_id, references(:clients, on_delete: :delete_all)
      add :order, :integer

      timestamps()
    end

    alter table("tasks") do
      add :workflow_id, references(:workflows, on_delete: :delete_all)
    end

    create index(:workflows, [:client_id])
  end
end
