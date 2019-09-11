defmodule FocalApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :avatar, :string
      add :email, :string
      add :first_name, :string
      add :provider, :string
      add :uuid, :uuid

      timestamps()
    end

  end
end
