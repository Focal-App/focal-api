defmodule FocalApiWeb.Plugs.AuthorizeUserByPackageUUID do
  import Plug.Conn
  use FocalApiWeb, :controller

  alias FocalApi.Clients
  alias FocalApi.Repo
  alias FocalApi.Accounts

  def init(_params) do
  end

  def call(conn, _params) do
    package = conn.params["package_uuid"]
    |> Clients.get_package_by_uuid!
    |> Repo.preload(:client)

    packages_user = Accounts.get_user!(package.client.user_id)

    current_user = conn.assigns[:user]

    if current_user != nil && packages_user.uuid == current_user.uuid do
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
