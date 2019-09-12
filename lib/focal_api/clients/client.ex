defmodule FocalApi.Clients.Client do
  use Ecto.Schema
  import Ecto.Changeset
  alias FocalApi.Accounts.User

  schema "clients" do
    field :client_name, :string
    field :uuid, Ecto.UUID
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [:client_name, :uuid, :user_id])
    |> validate_required([:client_name, :uuid])
  end
end
