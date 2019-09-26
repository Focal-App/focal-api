defmodule FocalApiWeb.WorkflowController do
  use FocalApiWeb, :controller

  alias FocalApi.Clients
  alias FocalApi.Clients.Workflow

  action_fallback FocalApiWeb.FallbackController

  plug FocalApiWeb.Plugs.AuthenticateSession when action in [:create, :update, :delete, :index_by_client, :show]
  plug FocalApiWeb.Plugs.AuthorizeUserByClientUUID when action in [:create, :index_by_client]
  plug FocalApiWeb.Plugs.AuthorizeUserByWorkflowUUID when action in [:update, :delete, :show]

  def index_by_client(conn, _params) do
    workflows = Clients.list_workflows_by_client(conn.params["client_uuid"])
    render(conn, "index.json", workflows: workflows)
  end

  def create(conn, params) do
    client = Clients.get_client_by_uuid!(params["client_uuid"])

    create_attrs = params
    |> Map.put("client_id", client.id)
    |> Map.put_new("uuid", Ecto.UUID.generate)

    with {:ok, %Workflow{} = workflow} <- Clients.create_workflow(create_attrs) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.workflow_path(conn, :show, workflow))
      |> render("show.json", workflow: workflow)
    end
  end

  def show(conn, %{"workflow_uuid" => workflow_uuid}) do
    workflow = Clients.get_workflow_by_uuid!(workflow_uuid)
    render(conn, "show.json", workflow: workflow)
  end

  def update(conn, params) do
    workflow = Clients.get_workflow_by_uuid!(params["workflow_uuid"])

    update_attrs = params
    |> Map.put("uuid", workflow.uuid)

    with {:ok, %Workflow{} = workflow} <- Clients.update_workflow(workflow, update_attrs) do
      render(conn, "show.json", workflow: workflow)
    end
  end

  def delete(conn, %{"workflow_uuid" => workflow_uuid}) do
    workflow = Clients.get_workflow_by_uuid!(workflow_uuid)

    with {:ok, %Workflow{}} <- Clients.delete_workflow(workflow) do
      send_resp(conn, :no_content, "")
    end
  end
end
