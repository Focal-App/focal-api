defmodule FocalApi.Repo.Migrations.UpdateClientsTable do
  use Ecto.Migration

  def change do
    alter table("clients") do
      add :user_id, references(:users)
    end
  end
end
