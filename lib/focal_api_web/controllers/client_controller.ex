defmodule FocalApiWeb.ClientController do
  use FocalApiWeb, :controller

  alias FocalApi.Clients
  alias FocalApi.Clients.Client
  alias FocalApi.Accounts
  alias FocalApi.Repo


  action_fallback FocalApiWeb.FallbackController

  plug FocalApiWeb.Plugs.AuthenticateSession when action in [:create, :update, :delete, :index_by_user, :show]
  plug :authorize_user_by_client_uuid when action in [:update, :delete, :show]
  plug :authorize_user_by_user_uuid when action in [:index_by_user]

  def index_by_user(conn, %{"user_uuid" => user_uuid}) do
    clients = Clients.list_clients_by_user(user_uuid)
    render(conn, "index.json", clients: clients)
  end

  def create(conn, params) do
    current_user = conn.assigns[:user]

    create_attrs = params
    |> Map.put("user_id", current_user.id)
    |> Map.put_new("uuid", Ecto.UUID.generate)

    with {:ok, %Client{} = client} <- Clients.create_client(create_attrs) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.client_path(conn, :show, client))
      |> render("show.json", client: client)
    end
  end

  def show(conn, %{"client_uuid" => client_uuid}) do
    client = Clients.get_client_by_uuid!(client_uuid)
    render(conn, "show.json", client: client)
  end

  def update(conn, params) do
    client_uuid = params["client_uuid"]
    client = Clients.get_client_by_uuid!(client_uuid)

    update_attrs = params
    |> Map.put("uuid", client_uuid)

    with {:ok, %Client{} = client} <- Clients.update_client(client, update_attrs) do
      render(conn, "show.json", client: client)
    end
  end

  def delete(conn, %{"client_uuid" => client_uuid}) do
    client = Clients.get_client_by_uuid!(client_uuid)

    with {:ok, %Client{}} <- Clients.delete_client(client) do
      send_resp(conn, :no_content, "")
    end
  end

  defp authorize_user_by_client_uuid(conn, _params) do
    client = conn.params["client_uuid"]
    |> Clients.get_client_by_uuid!
    |> Repo.preload(:user)

    clients_user = Accounts.get_user!(client.user_id)

    current_user = conn.assigns[:user]

    if current_user != nil && clients_user.uuid == current_user.uuid do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> put_view(FocalApiWeb.ErrorView)
      |> render("403.json")
      |> halt()
    end
  end

  defp authorize_user_by_user_uuid(conn, _params) do
    requested_users_uuid = conn.params["user_uuid"]
    current_user = conn.assigns[:user]

    if current_user != nil && requested_users_uuid == current_user.uuid do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> put_view(FocalApiWeb.ErrorView)
      |> render("403.json")
      |> halt()
    end
  end
end
