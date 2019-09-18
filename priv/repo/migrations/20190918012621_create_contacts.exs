defmodule FocalApi.Repo.Migrations.CreateContact do
  use Ecto.Migration

  def change do
    create_if_not_exists table("contacts") do
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :phone_number, :string
      add :best_time_to_contact, :string
      add :uuid, :uuid
      add :label, :string
      timestamps()
    end

    alter table("contacts") do
      add :client_id, references(:clients, on_delete: :nilify_all)
    end

    alter table("clients") do
      remove_if_exists :client_first_name, :string
      remove_if_exists :client_last_name, :string
      remove_if_exists :client_email, :string
      remove_if_exists :client_phone_number, :string
    end
  end
end
