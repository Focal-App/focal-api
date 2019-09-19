defmodule FocalApi.Clients.Client do
  use Ecto.Schema
  import Ecto.Changeset
  alias FocalApi.Accounts.User
  alias FocalApi.Accounts.Contact
  alias FocalApi.Clients.Package
  alias FocalApi.Clients.Event

  schema "clients" do
    field :private_notes, :string
    field :uuid, Ecto.UUID

    belongs_to :user, User
    has_many :packages, Package
    has_many :events, Event
    has_many :contacts, Contact

    timestamps()
  end

  def changeset(client, attrs) do
    client
    |> cast(attrs, [:private_notes, :uuid, :user_id])
    |> validate_required([:uuid])
  end
end
