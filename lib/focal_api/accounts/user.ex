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
    field :google_refresh_token, :string
    field :google_access_token, :string
    field :google_id, :string
    has_many :clients, Client

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :avatar,
      :email,
      :first_name,
      :provider,
      :uuid,
      :google_refresh_token,
      :google_access_token,
      :google_id
    ])
    |> validate_required([:avatar, :email, :first_name, :provider, :uuid])
  end
end
