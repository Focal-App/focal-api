defmodule FocalApi.Clients.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias FocalApi.Clients.Package
  alias FocalApi.Clients.Client

  schema "events" do
    field :event_name, :string
    field :shoot_date, :utc_datetime
    field :shoot_time, :string
    field :shoot_location, :string
    field :edit_image_deadline, :utc_datetime
    field :gallery_link, :string
    field :blog_link, :string
    field :wedding_location, :string
    field :reception_location, :string
    field :coordinator_name, :string
    field :notes, :string
    field :uuid, Ecto.UUID

    belongs_to :client, Client
    belongs_to :package, Package

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :event_name,
      :shoot_date,
      :uuid,
      :client_id,
      :package_id,
      :shoot_time,
      :shoot_location,
      :edit_image_deadline,
      :gallery_link,
      :blog_link,
      :notes,
      :wedding_location,
      :reception_location,
      :coordinator_name
    ])
    |> validate_required([:event_name, :uuid])
  end
end
