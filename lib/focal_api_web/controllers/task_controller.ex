defmodule FocalApiWeb.TaskController do
  use FocalApiWeb, :controller

  alias FocalApi.Clients
  alias FocalApi.Clients.Task
  alias FocalApi.Accounts
  alias FocalApi.Repo

  action_fallback FocalApiWeb.FallbackController
  plug FocalApiWeb.Plugs.AuthenticateSession when action in [:create, :update, :delete, :index_by_client, :show]
  plug FocalApiWeb.Plugs.AuthorizeUserByClientUUID when action in [:index_by_client, :create]
  plug :authorize_user_by_task_uuid when action in [:update, :delete, :show]

  def index_by_client(conn, _params) do
    tasks = Clients.list_tasks_by_client(conn.params["client_uuid"])
    render(conn, "index.json", tasks: tasks)
  end

  def create(conn, params) do
    client = params["client_uuid"]
    |> Clients.get_client_by_uuid!()

    event = params["event_uuid"]
    |> Clients.get_event_by_uuid()

    event_id = cond do
      event == nil -> nil
      true -> event.id
    end

    create_attrs = params
    |> Map.put("client_id", client.id)
    |> Map.put("event_id", event_id)
    |> Map.put_new("uuid", Ecto.UUID.generate)

    with {:ok, %Task{} = task} <- Clients.create_task(create_attrs) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.task_path(conn, :show, task))
      |> render("show.json", task: task)
    end
  end

  def show(conn, %{"task_uuid" => task_uuid}) do
    task = Clients.get_task_by_uuid!(task_uuid)
    render(conn, "show.json", task: task)
  end

  def update(conn, params) do
    task = Clients.get_task_by_uuid!(params["task_uuid"])

    update_attrs = params
    |> Map.put("uuid", task.uuid)

    with {:ok, %Task{} = task} <- Clients.update_task(task, update_attrs) do
      render(conn, "show.json", task: task)
    end
  end

  def delete(conn, %{"task_uuid" => task_uuid}) do
    task = Clients.get_task_by_uuid!(task_uuid)

    with {:ok, %Task{}} <- Clients.delete_task(task) do
      send_resp(conn, :no_content, "")
    end
  end

  defp authorize_user_by_task_uuid(conn, _params) do
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
