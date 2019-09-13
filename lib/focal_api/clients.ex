defmodule FocalApi.Clients do
  import Ecto.Query, warn: false
  alias FocalApi.Repo
  alias FocalApi.Clients.Client
  alias FocalApi.Accounts

  def list_clients do
    Repo.all(Client)
  end

  def list_clients_by_user(user_uuid) do
    user = Accounts.get_user_by_uuid!(user_uuid)
    query = from client in Client, where: ^user.id == client.user_id
    Repo.all(query, preload: [:user])
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

  alias FocalApi.Clients.Event

  def list_events do
    Repo.all(Event)
  end

  def list_events_by_package(package_uuid) do
    package = get_package_by_uuid!(package_uuid)
    query = from event in Event, where: ^package.id == event.package_id
    Repo.all(query, preload: [:package])
  end

  def get_event!(id), do: Repo.get!(Event, id)

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
    query = from task in Task, where: ^event.id == task.event_id
    Repo.all(query, preload: [:event])
  end

  def list_tasks_by_client(client_uuid) do
    client = get_client_by_uuid!(client_uuid)
    query = from task in Task, where: ^client.id == task.client_id
    Repo.all(query, preload: [:client])
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
end
