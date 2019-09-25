defmodule FocalApiWeb.Plugs.AuthorizeUserByUserUUID do
  import Plug.Conn
  use FocalApiWeb, :controller

  def init(_params) do
  end

  def call(conn, _params) do
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
