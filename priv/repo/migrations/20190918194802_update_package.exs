defmodule FocalApi.Repo.Migrations.UpdatePackage do
  use Ecto.Migration

  def change do
    alter table("packages") do
      add :proposal_signed, :boolean
      add :package_contents, :text
      add :package_price, :integer
      add :retainer_price, :integer
      add :retainer_paid_amount, :integer
      add :retainer_paid, :boolean
      add :discount_offered, :integer
      add :balance_remaining, :integer
      add :balance_received, :boolean

    end
  end
end
