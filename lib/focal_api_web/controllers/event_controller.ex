defmodule FocalApiWeb.EventController do
  use FocalApiWeb, :controller

  alias FocalApi.Clients
  alias FocalApi.Clients.Event
  alias FocalApi.Repo
  alias FocalApi.Accounts

  action_fallback FocalApiWeb.FallbackController

  plug FocalApiWeb.Plugs.AuthenticateSession when action in [:create, :update, :delete, :index_by_package, :show]
  plug FocalApiWeb.Plugs.AuthorizeUserByPackageUUID when action in [:index_by_package, :create]
  plug :authorize_user_by_event_uuid when action in [:update, :delete, :show]

  def index_by_package(conn, %{"package_uuid" => package_uuid}) do
    events = Clients.list_events_by_package(package_uuid)
    render(conn, "index.json", events: events)
  end

  def create(conn, params) do
    package = params["package_uuid"]
    |> Clients.get_package_by_uuid!()
    |> Repo.preload(:client)

    create_attrs = params
    |> Map.put("client_id", package.client.id)
    |> Map.put("package_id", package.id)
    |> Map.put_new("uuid", Ecto.UUID.generate)

    with {:ok, %Event{} = event} <- Clients.create_event(create_attrs) do
      package = Clients.get_package!(event.package_id)
      events = Clients.list_events_by_package(package.uuid)

      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.event_path(conn, :index_by_package, package.uuid))

      render(conn, "index.json", events: events)
    end
  end

  def show(conn, %{"event_uuid" => event_uuid}) do
    event = Clients.get_event_by_uuid!(event_uuid)
    render(conn, "show.json", event: event)
  end

  def update(conn, params) do
    event = Clients.get_event_by_uuid!(params["event_uuid"])

    update_attrs = params
    |> Map.put("uuid", event.uuid)

    with {:ok, %Event{} = event} <- Clients.update_event(event, update_attrs) do
      package = Clients.get_package!(event.package_id)
      events = Clients.list_events_by_package(package.uuid)
      render(conn, "index.json", events: events)
    end
  end

  def delete(conn, %{"event_uuid" => event_uuid}) do
    event = Clients.get_event_by_uuid!(event_uuid)

    with {:ok, %Event{}} <- Clients.delete_event(event) do
      package = Clients.get_package!(event.package_id)
      events = Clients.list_events_by_package(package.uuid)
      render(conn, "index.json", events: events)
    end
  end

  defp authorize_user_by_event_uuid(conn, _params) do
    event = conn.params["event_uuid"]
    |> Clients.get_event_by_uuid!
    |> Repo.preload(:client)

    events_user = Accounts.get_user!(event.client.user_id)

    current_user = conn.assigns[:user]

    if current_user != nil && events_user.uuid == current_user.uuid do
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
