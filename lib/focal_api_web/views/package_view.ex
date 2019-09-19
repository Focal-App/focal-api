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
    %{
      package_name: package.package_name,
      uuid: package.uuid,
      client_uuid: client_uuid(package.uuid),
      proposal_signed: package.proposal_signed,
      package_contents: package.package_contents,
      package_price: package.package_price,
      retainer_price: package.retainer_price,
      retainer_paid_amount: package.retainer_paid_amount,
      retainer_paid: package.retainer_paid,
      discount_offered: package.discount_offered,
      balance_remaining: package.balance_remaining,
      balance_received: package.balance_received,
      wedding_included: package.wedding_included,
      engagement_included: package.engagement_included,
    }
  end

  def render("package_with_events.json", %{package: package}) do
    package_events = Clients.list_events_by_package(package.uuid)
    %{
      package_name: package.package_name,
      uuid: package.uuid,
      client_uuid: client_uuid(package.uuid),
      package_events: render_many(package_events, EventView, "event.json"),
      proposal_signed: package.proposal_signed,
      package_contents: package.package_contents,
      package_price: package.package_price,
      retainer_price: package.retainer_price,
      retainer_paid_amount: package.retainer_paid_amount,
      retainer_paid: package.retainer_paid,
      discount_offered: package.discount_offered,
      balance_remaining: package.balance_remaining,
      balance_received: package.balance_received,
      wedding_included: package.wedding_included,
      engagement_included: package.engagement_included,
      upcoming_shoot_date: upcoming_shoot_date(package, package_events),
    }
  end

  defp client_uuid(uuid) do
    package = preloaded_package(uuid)
    package.client.uuid
  end

  defp preloaded_package(uuid) do
    uuid
    |> Clients.get_package_by_uuid!
    |> Repo.preload(:client)
  end

  defp upcoming_shoot_date(package, package_events) do
    package_exists = package != nil && length(package_events) > 0
    if package_exists, do: Clients.get_earliest_shoot_date_by_package(package.uuid), else: nil
  end
end
