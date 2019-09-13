defmodule FocalApiWeb.PackageController do
  use FocalApiWeb, :controller

  alias FocalApi.Clients
  alias FocalApi.Clients.Package

  action_fallback FocalApiWeb.FallbackController

  plug FocalApiWeb.Plugs.AuthenticateSession when action in [:create, :update, :delete, :index, :show]
  plug FocalApiWeb.Plugs.AuthorizeUserByClientUUID when action in [:create, :update, :delete, :show, :index]

  def index(conn, _params) do
    packages = Clients.list_packages()
    render(conn, "index.json", packages: packages)
  end

  def create(conn, params) do
    client = Clients.get_client_by_uuid!(params["client_uuid"])

    create_attrs = params
    |> Map.put("client_id", client.id)
    |> Map.put_new("uuid", Ecto.UUID.generate)

    with {:ok, %Package{} = package} <- Clients.create_package(create_attrs) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.package_path(conn, :show, params["client_uuid"], package.uuid))
      |> render("show.json", package: package)
    end
  end

  def show(conn, %{"package_uuid" => package_uuid}) do
    package = Clients.get_package_by_uuid!(package_uuid)
    render(conn, "show.json", package: package)
  end

  def update(conn, params) do
    package = Clients.get_package_by_uuid!(params["package_uuid"])

    update_attrs = params
    |> Map.put("uuid", package.uuid)

    with {:ok, %Package{} = package} <- Clients.update_package(package, update_attrs) do
      render(conn, "show.json", package: package)
    end
  end

  def delete(conn, %{"package_uuid" => package_uuid}) do
    package = Clients.get_package_by_uuid!(package_uuid)

    with {:ok, %Package{}} <- Clients.delete_package(package) do
      send_resp(conn, :no_content, "")
    end
  end
end
