defmodule FocalApiWeb.ClientView do
  use FocalApiWeb, :view
  alias FocalApiWeb.ClientView
  alias FocalApiWeb.TaskView
  alias FocalApiWeb.PackageView
  alias FocalApiWeb.ContactView
  alias FocalApiWeb.WorkflowView
  alias FocalApi.Clients.Client
  alias FocalApi.Clients
  alias FocalApi.Repo

  def render("index.json", %{clients: clients}) do
    %{data: render_many(clients, ClientView, "client.json")}
  end

  def render("index_of_all_client_data.json", %{clients: clients}) do
    %{data: render_many(clients, ClientView, "all_client_data.json")}
  end

  def render("index_of_partial_client_data.json", %{clients: clients}) do
    %{data: render_many(clients, ClientView, "partial_client_data.json")}
  end

  def render("show.json", %{client: client}) do
    %{data: render_one(client, ClientView, "client.json")}
  end

  def render("show_all_client_data.json", %{client: client}) do
    %{data: render_one(client, ClientView, "all_client_data.json")}
  end

  def render("client.json", %{client: client}) do
    client = preloaded_client(client.uuid)
    %{
      contacts: render_many(client.contacts, ContactView, "contact.json"),
      private_notes: client.private_notes,
      uuid: client.uuid,
      user_uuid: user_uuid(client.uuid)
    }
  end

  def render("all_client_data.json", %{client: client}) do
    client = preloaded_client(client.uuid)
    %{
      contacts: render_many(client.contacts, ContactView, "contact.json"),
      private_notes: client.private_notes,
      uuid: client.uuid,
      user_uuid: user_uuid(client.uuid),
      package: package(client.uuid),
      current_stage: current_stage(client.uuid),
      workflows: workflows(client.uuid)
    }
  end

  def render("partial_client_data.json", %{client: client}) do
    client = preloaded_client(client.uuid)
    package = package(client.uuid)
    %{
      client_first_name: client_first_name(client),
      partner_first_name: partner_first_name(client),
      package_name: package_name(package),
      upcoming_shoot_date: upcoming_shoot_date(package),
      current_stage: current_stage(client.uuid),
      uuid: client.uuid
    }
  end

  defp user_uuid(uuid) do
    client = preloaded_client(uuid)
    client.user.uuid
  end

  def preloaded_client(uuid) do
    Client
    |> Repo.get_by!(uuid: uuid)
    |> Repo.preload(:user)
    |> Repo.preload(:contacts)
  end

  defp package(client_uuid) do
    packages = Clients.list_packages_by_client(client_uuid)
    render_one(Enum.at(packages, 0), PackageView, "package_with_events.json")
  end

  defp package_name(package) do
    if (package != nil), do: package.package_name, else: nil
  end

  defp upcoming_shoot_date(package) do
    package_exists = package != nil && length(package.package_events) > 0
    if package_exists, do: Clients.get_earliest_shoot_date_by_package(package.uuid), else: nil
  end

  defp current_stage(client_uuid) do
    first_uncompleted_task = Clients.list_first_uncompleted_task_by_client(client_uuid)
    if (length(first_uncompleted_task) == 0), do: %{}, else: render_one(Enum.at(first_uncompleted_task, 0), TaskView, "task.json")
  end

  defp partner_first_name(client) do
    if (length(client.contacts) > 1), do: Enum.at(client.contacts, 1).first_name, else: nil
  end

  defp client_first_name(client) do
    if (List.first(client.contacts) != nil), do: List.first(client.contacts).first_name, else: nil
  end

  defp workflows(client_uuid) do
    client_uuid
    |> Clients.list_workflows_by_client()
    |> render_many(WorkflowView, "workflow.json")
  end
end
