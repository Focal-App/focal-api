defmodule FocalApi.Repo.Migrations.UpdateClient do
  use Ecto.Migration

  def change do
    alter table("clients") do
      remove_if_exists :client_name, :string
      add_if_not_exists :client_first_name, :string
      add :client_last_name, :string
      add :client_email, :string
      add :client_phone_number, :string
      add :private_notes, :text
    end
  end

  def down do
    drop_if_exists table("clients")
  end
end
