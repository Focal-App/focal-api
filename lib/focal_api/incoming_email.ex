defmodule FocalApi.IncomingEmail do
  use Ecto.Schema
  import Ecto.Changeset

  schema "incoming_emails" do
    field :content, :string
    field :recipients, {:array, :string}
    field :sender, :string
    field :subject, :string

    timestamps()
  end

  def changeset(email, attrs) do
    email
    |> cast(attrs, [:sender, :recipients, :subject, :content])
    |> validate_required([:recipients, :subject, :content])
  end
end
