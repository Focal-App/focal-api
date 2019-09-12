defmodule FocalApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias FocalApi.Clients.Client

  schema "users" do
    field :avatar, :string
    field :email, :string
    field :first_name, :string
    field :provider, :string
    field :uuid, Ecto.UUID
    has_many :clients, Client

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:avatar, :email, :first_name, :provider, :uuid])
    |> validate_required([:avatar, :email, :first_name, :provider, :uuid])
  end
end
