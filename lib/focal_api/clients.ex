defmodule FocalApi.Clients do
  import Ecto.Query, warn: false
  alias FocalApi.Repo
  alias FocalApi.Clients.Client
  alias FocalApi.Accounts
  alias FocalApi.Clients.Event
  alias FocalApi.EventName
  alias FocalApi.DefaultWorkflows

  def list_clients do
    Repo.all(Client)
  end

  def list_clients_by_user(user_uuid) do
    user = Accounts.get_user_by_uuid!(user_uuid)
    query = from client in Client, where: ^user.id == client.user_id
    Repo.all(query, preload: [:user, :contact])
  end

  def get_client!(id), do: Repo.get!(Client, id)

  def get_client_by_uuid!(uuid), do: Repo.get_by!(Client, uuid: uuid)

  def create_client(attrs \\ %{}) do
    %Client{}
    |> Client.changeset(attrs)
    |> Repo.insert()
  end

  def update_client(%Client{} = client, attrs) do
    client
    |> Client.changeset(attrs)
    |> Repo.update()
  end

  def delete_client(%Client{} = client) do
    Repo.delete(client)
  end

  def change_client(%Client{} = client) do
    Client.changeset(client, %{})
  end

  alias FocalApi.Clients.Package

  def list_packages do
    Repo.all(Package)
  end

  def list_packages_by_client(client_uuid) do
    client = get_client_by_uuid!(client_uuid)
    query = from package in Package, where: ^client.id == package.client_id
    Repo.all(query, preload: [:client])
  end

  def get_package!(id), do: Repo.get!(Package, id)

  def get_package_by_uuid!(uuid), do: Repo.get_by!(Package, uuid: uuid)

  def get_earliest_shoot_date_by_package(package_uuid) do
    package = get_package_by_uuid!(package_uuid)
    query = from event in Event,
              where: ^package.id == event.package_id,
              order_by: event.shoot_date,
              limit: 1
    Repo.one(query, preload: [:event]).shoot_date
  end

  def create_package(attrs \\ %{}) do
    %Package{}
    |> Package.changeset(attrs)
    |> Repo.insert()
  end

  def update_package(%Package{} = package, attrs) do
    package
    |> Package.changeset(attrs)
    |> Repo.update()
  end

  def delete_package(%Package{} = package) do
    Repo.delete(package)
  end

  def change_package(%Package{} = package) do
    Package.changeset(package, %{})
  end


  def list_events do
    Repo.all(Event)
  end

  def list_events_by_package(package_uuid) do
    package = get_package_by_uuid!(package_uuid)
    query = from event in Event, where: ^package.id == event.package_id, order_by: event.event_name
    Repo.all(query, preload: [:package])
  end

  def get_event!(id), do: Repo.get!(Event, id)

  def get_event(id) do
    id
    |> gracefully_handle_id_get
  end

  defp gracefully_handle_id_get(nil), do: nil
  defp gracefully_handle_id_get(id), do: Repo.get_by(Event, id: id)

  def get_event_by_uuid!(uuid), do: Repo.get_by!(Event, uuid: uuid)

  def get_event_by_uuid(event_uuid) do
    event_uuid
    |> gracefully_handle_get
  end

  defp gracefully_handle_get(nil), do: nil
  defp gracefully_handle_get(event_uuid), do: Repo.get_by(Event, uuid: event_uuid)

  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  def change_event(%Event{} = event) do
    Event.changeset(event, %{})
  end

  alias FocalApi.Clients.Task

  def list_tasks do
    Repo.all(Task)
  end

  def list_tasks_by_event(event_uuid) do
    event = get_event_by_uuid!(event_uuid)
    query = from task in Task, where: ^event.id == task.event_id, order_by: task.order
    Repo.all(query, preload: [:event])
  end

  def list_tasks_by_client(client_uuid) do
    client = get_client_by_uuid!(client_uuid)
    query = from task in Task, where: ^client.id == task.client_id, order_by: task.order
    Repo.all(query, preload: [:client])
  end

  def list_first_uncompleted_task_by_client(client_uuid) do
    client = get_client_by_uuid!(client_uuid)
    query = from task in Task,
              where: ^client.id == task.client_id and task.is_completed == false,
              order_by: task.order,
              limit: 1
    Repo.all(query, preload: [:client])
  end

  def list_incomplete_tasks_by_workflow(workflow_uuid) do
    workflow = get_workflow_by_uuid!(workflow_uuid) |> Repo.preload(:task)
    query = from task in Task,
              where: ^workflow.id == task.workflow_id and task.is_completed == false
    Repo.all(query, preload: [:workflow])
  end

  def list_completed_tasks_by_workflow(workflow_uuid) do
    workflow = get_workflow_by_uuid!(workflow_uuid) |> Repo.preload(:task)
    query = from task in Task,
              where: ^workflow.id == task.workflow_id and task.is_completed == true
    Repo.all(query, preload: [:workflow])
  end

  def list_tasks_by_workflow(workflow_uuid) do
    workflow = get_workflow_by_uuid!(workflow_uuid) |> Repo.preload(:task)
    query = from task in Task,
              where: ^workflow.id == task.workflow_id,
              order_by: task.order
    Repo.all(query, preload: [:workflow])
  end

  def get_task!(id), do: Repo.get!(Task, id)

  def get_task_by_uuid!(uuid), do: Repo.get_by!(Task, uuid: uuid)

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  def change_task(%Task{} = task) do
    Task.changeset(task, %{})
  end

  alias FocalApi.Clients.Workflow

  def list_workflows do
    Repo.all(Workflow)
  end

  def list_workflows_by_client(client_uuid) do
    client = get_client_by_uuid!(client_uuid)
    query = from workflow in Workflow, where: ^client.id == workflow.client_id, order_by: workflow.order
    Repo.all(query, preload: [:client])
  end

  def get_workflow!(id), do: Repo.get!(Workflow, id)

  def get_workflow_by_uuid!(uuid), do: Repo.get_by!(Workflow, uuid: uuid)

  def create_workflow(attrs \\ %{}) do
    %Workflow{}
    |> Workflow.changeset(attrs)
    |> Repo.insert()
  end

  def update_workflow(%Workflow{} = workflow, attrs) do
    workflow
    |> Workflow.changeset(attrs)
    |> Repo.update()
  end

  def delete_workflow(%Workflow{} = workflow) do
    Repo.delete(workflow)
  end

  def change_workflow(%Workflow{} = workflow) do
    Workflow.changeset(workflow, %{})
  end

  def handle_engagement_and_wedding_updates(package) do
    client = get_client!(package.client_id)
    events = list_events_by_package(package.uuid)
    workflows = list_workflows_by_client(client.uuid)
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
    delete_workflow_by_name(workflows, name)
    delete_event_by_name(events, name)
  end

  defp delete_workflow_by_name(workflows, workflow_name) do
    workflows
    |> Enum.find(fn workflow -> workflow.workflow_name == workflow_name end)
    |> delete_workflow()
  end

  defp delete_event_by_name(events, event_name) do
    event = events
    |> Enum.find(fn event -> event.event_name == event_name end)

    if (event != nil) do
      event
      |> delete_event()
    end
  end
end
