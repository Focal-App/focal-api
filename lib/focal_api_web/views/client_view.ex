defmodule FocalApiWeb.ClientView do
  use FocalApiWeb, :view
  alias FocalApiWeb.ClientView

  def render("index.json", %{clients: clients}) do
    %{data: render_many(clients, ClientView, "client.json")}
  end

  def render("show.json", %{client: client}) do
    %{data: render_one(client, ClientView, "client.json")}
  end

  def render("client.json", %{client: client}) do
    %{client_name: client.client_name,
      uuid: client.uuid}
  end
end
