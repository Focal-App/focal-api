defmodule FocalApiWeb.Plugs.AuthorizeUserByClientUUID do
  import Plug.Conn
  use FocalApiWeb, :controller

  alias FocalApi.Clients
  alias FocalApi.Repo
  alias FocalApi.Accounts

  def init(_params) do
  end

  def call(conn, _params) do
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
end
