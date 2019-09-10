defmodule FocalApi.Clients.Client do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clients" do
    field :client_name, :string
    field :uuid, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [:client_name, :uuid])
    |> validate_required([:client_name, :uuid])
  end
end
