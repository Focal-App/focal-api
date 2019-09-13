defmodule FocalApi.Clients.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias FocalApi.Clients.Package
  alias FocalApi.Clients.Client

  schema "events" do
    field :event_name, :string
    field :shoot_date, :utc_datetime
    field :uuid, Ecto.UUID
    belongs_to :client, Client
    belongs_to :package, Package

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:event_name, :shoot_date, :uuid, :client_id, :package_id])
    |> validate_required([:event_name, :shoot_date, :uuid])
  end
end
