defmodule FocalApiWeb.EventView do
  use FocalApiWeb, :view
  alias FocalApiWeb.EventView
  alias FocalApi.Clients

  def render("index.json", %{events: events}) do
    %{data: render_many(events, EventView, "event.json")}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, EventView, "event.json")}
  end

  def render("event.json", %{event: event}) do
    client = Clients.get_client!(event.client_id)
    package = Clients.get_package!(event.package_id)
    %{
      event_name: event.event_name,
      shoot_date: event.shoot_date,
      uuid: event.uuid,
      package_uuid: package.uuid,
      client_uuid: client.uuid
    }
  end
end
