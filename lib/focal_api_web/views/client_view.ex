defmodule FocalApiWeb.ClientView do
  use FocalApiWeb, :view
  alias FocalApiWeb.ClientView
  alias FocalApi.Clients.Client
  alias FocalApi.Repo

  def render("index.json", %{clients: clients}) do
    %{data: render_many(clients, ClientView, "client.json")}
  end

  def render("show.json", %{client: client}) do
    %{data: render_one(client, ClientView, "client.json")}
  end

  def render("client.json", %{client: client}) do
    user_uuid = user_uuid(client.uuid)
    %{
      client_name: client.client_name,
      uuid: client.uuid,
      user_uuid: user_uuid
    }
  end

  defp user_uuid(uuid) do
    client = Client
    |> Repo.get_by!(uuid: uuid)
    |> Repo.preload(:user)

    client.user.uuid
  end
end
