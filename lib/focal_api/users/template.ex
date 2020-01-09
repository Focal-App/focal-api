defmodule FocalApi.Users.Template do
  use Ecto.Schema
  import Ecto.Changeset

  schema "templates" do
    field :template_category, :string
    field :template_content, :string
    field :template_name, :string
    field :uuid, Ecto.UUID
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(template, attrs) do
    template
    |> cast(attrs, [:uuid, :template_name, :template_category, :template_content])
    |> validate_required([:template_name, :template_category, :template_content])
  end
end
