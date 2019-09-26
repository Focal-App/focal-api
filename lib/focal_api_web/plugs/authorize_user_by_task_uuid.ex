defmodule FocalApiWeb.Plugs.AuthorizeUserByTaskUUID do
  import Plug.Conn
  use FocalApiWeb, :controller

  alias FocalApi.Clients
  alias FocalApi.Repo
  alias FocalApi.Accounts

  def init(_params) do
  end

  def call(conn, _params) do
    task = conn.params["task_uuid"]
    |> Clients.get_task_by_uuid!
    |> Repo.preload(:client)

    tasks_user = Accounts.get_user!(task.client.user_id)

    current_user = conn.assigns[:user]

    if current_user != nil && tasks_user.uuid == current_user.uuid do
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
