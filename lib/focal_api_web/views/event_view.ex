defmodule FocalApiWeb.EventView do
  use FocalApiWeb, :view
  alias FocalApiWeb.EventView
  alias FocalApi.TestHelpers

  def render("index.json", %{events: events}) do
    %{data: render_many(events, EventView, "event.json")}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, EventView, "event.json")}
  end

  def render("event.json", %{event: event}) do
    event = TestHelpers.preloaded_event(event.uuid)
    %{
      event_name: event.event_name,
      shoot_date: event.shoot_date,
      uuid: event.uuid,
      package_uuid: event.package.uuid,
      client_uuid: event.client.uuid
    }
  end
end
