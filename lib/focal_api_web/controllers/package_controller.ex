defmodule FocalApiWeb.PackageController do
  use FocalApiWeb, :controller

  alias FocalApi.Clients
  alias FocalApi.Clients.Package
  alias FocalApi.DefaultWorkflows
  alias FocalApi.EventName

  action_fallback FocalApiWeb.FallbackController

  plug FocalApiWeb.Plugs.AuthenticateSession when action in [:create, :update, :delete, :index_by_client, :show]
  plug FocalApiWeb.Plugs.AuthorizeUserByClientUUID when action in [:create, :index_by_client]
  plug FocalApiWeb.Plugs.AuthorizeUserByPackageUUID when action in [:update, :delete, :show]

  def index_by_client(conn, %{"client_uuid" => client_uuid}) do
    packages = Clients.list_packages_by_client(client_uuid)
    render(conn, "index.json", packages: packages)
  end

  def create(conn, params) do
    client = Clients.get_client_by_uuid!(params["client_uuid"])

    create_attrs = params
    |> Map.put("client_id", client.id)
    |> Map.put_new("uuid", Ecto.UUID.generate)

    with {:ok, %Package{} = package} <- Clients.create_package(create_attrs) do
      if (package.engagement_included == true), do: DefaultWorkflows.create_engagement_workflow_and_tasks(client, 2)
      if (package.wedding_included == true), do: DefaultWorkflows.create_wedding_workflow_and_tasks(client, 3)
      with {:ok, _closeout_workflow} <- DefaultWorkflows.create_closeout_workflow_and_tasks(client, 4) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.package_path(conn, :show, package.uuid))
        |> render("show.json", package: package)
      end
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
      handle_engagement_and_wedding_updates(package)
      render(conn, "show.json", package: package)
    end
  end

  def delete(conn, %{"package_uuid" => package_uuid}) do
    package = Clients.get_package_by_uuid!(package_uuid)

    with {:ok, %Package{}} <- Clients.delete_package(package) do
      send_resp(conn, :no_content, "")
    end
  end

  defp handle_engagement_and_wedding_updates(package) do
    client = Clients.get_client!(package.client_id)
    events = Clients.list_events_by_package(package.uuid)
    workflows = Clients.list_workflows_by_client(client.uuid)
    workflow_has_engagement = workflows_include(workflows, EventName.engagement())
    workflow_has_wedding = workflows_include(workflows, EventName.wedding())

    if include_engagement?(package, workflow_has_engagement), do: DefaultWorkflows.create_engagement_workflow_and_tasks(client, 2)
    if include_wedding?(package, workflow_has_wedding), do: DefaultWorkflows.create_wedding_workflow_and_tasks(client, 3)
    if remove_engagement?(package, workflow_has_engagement), do: delete_workflow_and_event(workflows, events, EventName.engagement())
    if remove_wedding?(package, workflow_has_wedding), do: delete_workflow_and_event(workflows, events, EventName.wedding())
  end

  defp workflows_include(workflows, workflow_name) do
    workflows
    |> Enum.any?(fn workflow -> workflow.workflow_name == workflow_name end)
  end

  defp include_engagement?(package, workflow_has_engagement) do
    package.engagement_included == true && !workflow_has_engagement
  end

  defp include_wedding?(package, workflow_has_wedding) do
    package.wedding_included == true && !workflow_has_wedding
  end

  defp remove_engagement?(package, workflow_has_engagement) do
    package.engagement_included == false && workflow_has_engagement
  end

  defp remove_wedding?(package, workflow_has_wedding) do
    package.wedding_included == false && workflow_has_wedding
  end

  defp delete_workflow_and_event(workflows, events, name) do
    delete_workflow(workflows, name)
    delete_event(events, name)
  end

  defp delete_workflow(workflows, workflow_name) do
    workflows
    |> Enum.find(fn workflow -> workflow.workflow_name == workflow_name end)
    |> Clients.delete_workflow()
  end

  defp delete_event(events, event_name) do
    event = events
    |> Enum.find(fn event -> event.event_name == event_name end)

    if (event != nil) do
      event
      |> Clients.delete_event()
    end
  end
end
