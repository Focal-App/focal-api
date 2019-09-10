defmodule FocalApiWeb.ClientController do
  use FocalApiWeb, :controller

  alias FocalApi.Clients
  alias FocalApi.Clients.Client

  action_fallback FocalApiWeb.FallbackController

  def index(conn, _params) do
    clients = Clients.list_clients()
    render(conn, "index.json", clients: clients)
  end

  def create(conn, %{"client" => client_params}) do
    with {:ok, %Client{} = client} <- Clients.create_client(client_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.client_path(conn, :show, client))
      |> render("show.json", client: client)
    end
  end

  def show(conn, %{"uuid" => uuid}) do
    client = Clients.get_client_by_uuid!(uuid)
    render(conn, "show.json", client: client)
  end

  @spec update(any, map) :: any
  def update(conn, params) do
    client = Clients.get_client_by_uuid!(params["uuid"])

    with {:ok, %Client{} = client} <- Clients.update_client(client, params) do
      render(conn, "show.json", client: client)
    end
  end

  def delete(conn, %{"uuid" => uuid}) do
    client = Clients.get_client_by_uuid!(uuid)

    with {:ok, %Client{}} <- Clients.delete_client(client) do
      send_resp(conn, :no_content, "")
    end
  end
end
