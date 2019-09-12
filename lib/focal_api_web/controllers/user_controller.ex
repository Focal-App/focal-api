defmodule FocalApiWeb.UserController do
  use FocalApiWeb, :controller

  alias FocalApi.Accounts
  alias FocalApi.Accounts.User

  action_fallback FocalApiWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def index(conn, _params) do
    users = Accounts.list_users
    render(conn, "index.json", users: users)
  end

  def show(conn, %{"user_uuid" => user_uuid}) do
    user = Accounts.get_user_by_uuid!(user_uuid)
    render(conn, "show.json", user: user)
  end
end
