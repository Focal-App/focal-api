defmodule FocalApiWeb.PackageView do
  use FocalApiWeb, :view
  alias FocalApiWeb.PackageView
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

  defp client_uuid(uuid) do
    package = uuid
    |> Clients.get_package_by_uuid!
    |> Repo.preload(:client)

    package.client.uuid
  end
end
