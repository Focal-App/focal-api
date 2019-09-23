defmodule FocalApi.Clients.Workflow do
  use Ecto.Schema
  import Ecto.Changeset
  alias FocalApi.Clients.Client
  alias FocalApi.Clients.Task

  schema "workflows" do
    field :uuid, Ecto.UUID
    field :workflow_name, :string
    field :order, :integer

    belongs_to :client, Client
    has_many :task, Task

    timestamps()
  end

  @doc false
  def changeset(workflow, attrs) do
    workflow
    |> cast(attrs, [:uuid, :workflow_name, :client_id, :order])
    |> validate_required([:uuid, :workflow_name])
  end
end
