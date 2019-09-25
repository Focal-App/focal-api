defmodule FocalApiWeb.Plugs.AuthorizeUserByEventUUID do
  import Plug.Conn
  use FocalApiWeb, :controller

  alias FocalApi.Clients
  alias FocalApi.Repo
  alias FocalApi.Accounts

  def init(_params) do
  end

  def call(conn, _params) do
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
