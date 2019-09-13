defmodule FocalApiWeb.PackageView do
  use FocalApiWeb, :view
  alias FocalApiWeb.PackageView
  alias FocalApiWeb.EventView
  alias FocalApi.Clients
  alias FocalApi.Repo

  def render("index.json", %{packages: packages}) do
    %{data: render_many(packages, PackageView, "package.json")}
  end

  def render("show.json", %{package: package}) do
    %{data: render_one(package, PackageView, "package.json")}
  end

  def render("package.json", %{package: package}) do
    client_uuid = client_uuid(package.uuid)
    %{
      package_name: package.package_name,
      uuid: package.uuid,
      client_uuid: client_uuid
    }
  end

  def render("package_with_events.json", %{package: package}) do
    client_uuid = client_uuid(package.uuid)
    package_events = Clients.list_events_by_package(package.uuid)
    %{
      package_name: package.package_name,
      uuid: package.uuid,
      client_uuid: client_uuid,
      package_events: render_many(package_events, EventView, "event.json")
    }
  end

  defp client_uuid(uuid) do
    package = uuid
    |> Clients.get_package_by_uuid!
    |> Repo.preload(:client)

    package.client.uuid
  end
end
