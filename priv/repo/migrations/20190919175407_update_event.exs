defmodule FocalApi.Repo.Migrations.UpdateEvent do
  use Ecto.Migration

  def change do
    alter table("events") do
      add :shoot_time, :string
      add :shoot_location, :string
      add :edit_image_deadline, :utc_datetime
      add :gallery_link, :string
      add :blog_link, :string
      add :wedding_location, :string
      add :reception_location, :string
      add :coordinator_name, :string
      add :notes, :text
    end
  end
end
