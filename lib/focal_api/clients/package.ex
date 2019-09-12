defmodule FocalApi.Clients.Package do
  use Ecto.Schema
  import Ecto.Changeset
  alias FocalApi.Clients.Client

  schema "packages" do
    field :package_name, :string
    field :uuid, Ecto.UUID
    belongs_to :client, Client

    timestamps()
  end

  @doc false
  def changeset(package, attrs) do
    package
    |> cast(attrs, [:package_name, :uuid, :client_id])
    |> validate_required([:package_name, :uuid])
  end
end
