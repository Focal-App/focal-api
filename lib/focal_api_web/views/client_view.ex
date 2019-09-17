defmodule FocalApiWeb.ClientView do
  use FocalApiWeb, :view
  alias FocalApiWeb.ClientView
  alias FocalApiWeb.TaskView
  alias FocalApiWeb.PackageView
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
    user_uuid = user_uuid(client.uuid)
    %{
      client_first_name: client.client_first_name,
      client_last_name: client.client_last_name,
      client_email: client.client_email,
      client_phone_number: client.client_phone_number,
      private_notes: client.private_notes,
      uuid: client.uuid,
      user_uuid: user_uuid
    }
  end

  def render("all_client_data.json", %{client: client}) do
    user_uuid = user_uuid(client.uuid)
    packages = Clients.list_packages_by_client(client.uuid)
    first_uncompleted_task = Clients.list_first_uncompleted_task_by_client(client.uuid)
    current_stage = if (length(first_uncompleted_task) == 0), do: %{}, else: render_one(Enum.at(first_uncompleted_task, 0), TaskView, "task.json")
    package = render_one(Enum.at(packages, 0), PackageView, "package_with_events.json")

    %{
      client_first_name: client.client_first_name,
      client_last_name: client.client_last_name,
      client_email: client.client_email,
      client_phone_number: client.client_phone_number,
      private_notes: client.private_notes,
      uuid: client.uuid,
      user_uuid: user_uuid,
      package: package,
      current_stage: current_stage
    }
  end

  def render("partial_client_data.json", %{client: client}) do
    packages = Clients.list_packages_by_client(client.uuid)
    first_uncompleted_task = Clients.list_first_uncompleted_task_by_client(client.uuid)
    current_stage = if (length(first_uncompleted_task) == 0), do: %{}, else: render_one(Enum.at(first_uncompleted_task, 0), TaskView, "task.json")
    package = render_one(Enum.at(packages, 0), PackageView, "package_with_events.json")
    package_name = if (package != nil), do: package.package_name, else: nil
    upcoming_shoot_date = if (package != nil && length(package.package_events) > 0), do: Enum.at(package.package_events, 0).shoot_date, else: nil
    %{
      client_first_name: client.client_first_name,
      partner_first_name: client.client_last_name,
      package_name: package_name,
      upcoming_shoot_date: upcoming_shoot_date,
      current_stage: current_stage,
      uuid: client.uuid
    }
  end

  defp user_uuid(uuid) do
    client = Client
    |> Repo.get_by!(uuid: uuid)
    |> Repo.preload(:user)

    client.user.uuid
  end
end
