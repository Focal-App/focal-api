defmodule FocalApi.Clients.Package do
  use Ecto.Schema
  import Ecto.Changeset
  alias FocalApi.Clients.Client

  schema "packages" do
    field :package_name, :string
    field :proposal_signed, :boolean
    field :package_contents, :string
    field :package_price, :integer
    field :retainer_price, :integer
    field :retainer_paid_amount, :integer
    field :retainer_paid, :boolean
    field :discount_offered, :integer
    field :balance_remaining, :integer
    field :balance_received, :boolean
    field :wedding_included, :boolean
    field :engagement_included, :boolean

    field :uuid, Ecto.UUID
    belongs_to :client, Client

    timestamps()
  end

  @doc false
  def changeset(package, attrs) do
    package
    |> cast(attrs, [
      :package_name,
      :proposal_signed,
      :package_contents,
      :package_price,
      :retainer_price,
      :retainer_paid_amount,
      :retainer_paid,
      :discount_offered,
      :balance_remaining,
      :balance_received,
      :wedding_included,
      :engagement_included,
      :uuid,
      :client_id
      ])
    |> validate_required([:package_name, :uuid])
  end
end
