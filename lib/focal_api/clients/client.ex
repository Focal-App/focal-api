defmodule FocalApi.Clients.Client do
  use Ecto.Schema
  import Ecto.Changeset
  alias FocalApi.Accounts.User
  alias FocalApi.Clients.Package
  alias FocalApi.Clients.Event

  schema "clients" do
    field :client_first_name, :string
    field :client_last_name, :string
    field :client_email, :string
    field :client_phone_number, :string
    field :private_notes, :string
    field :uuid, Ecto.UUID

    belongs_to :user, User
    has_many :packages, Package
    has_many :events, Event

    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [:client_first_name, :client_last_name, :client_email, :client_phone_number, :private_notes, :uuid, :user_id])
    |> validate_required([:client_first_name, :uuid])
    |> validate_format(:client_email, ~r/@/)
  end
end
