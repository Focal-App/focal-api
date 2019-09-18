defmodule FocalApi.Accounts.Contact do
  use Ecto.Schema
  import Ecto.Changeset
  alias FocalApi.Clients.Client

  schema "contacts" do
    field :best_time_to_contact, :string
    field :email, :string
    field :first_name, :string
    field :label, :string
    field :last_name, :string
    field :phone_number, :string
    field :uuid, Ecto.UUID

    belongs_to :client, Client
    timestamps()
  end

  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:first_name, :last_name, :email, :phone_number, :best_time_to_contact, :uuid, :label, :client_id])
    |> validate_required([:first_name, :uuid])
    |> validate_format(:email, ~r/@/)
    |> foreign_key_constraint(:client_id)
    |> assoc_constraint(:client)
  end
end
