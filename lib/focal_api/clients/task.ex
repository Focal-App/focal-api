defmodule FocalApi.Clients.Task do
  use Ecto.Schema
  import Ecto.Changeset
  alias FocalApi.Clients.Client
  alias FocalApi.Clients.Event

  schema "tasks" do
    field :category, :string
    field :is_completed, :boolean, default: false
    field :step, :string
    field :uuid, Ecto.UUID
    belongs_to :event, Event
    belongs_to :client, Client

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:uuid, :category, :step, :is_completed, :event_id, :client_id])
    |> validate_required([:uuid, :category, :step, :is_completed])
  end
end
