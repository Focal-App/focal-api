defmodule FocalApi.Repo.Migrations.CreateTemplates do
  use Ecto.Migration

  def change do
    create table(:templates) do
      add :uuid, :uuid
      add :template_name, :string
      add :template_category, :string
      add :template_content, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:templates, [:user_id])
  end
end
