defmodule FocalApiWeb.EventControllerTest do
  use FocalApiWeb.ConnCase

  alias FocalApi.Clients
  alias FocalApi.Clients.Event
  alias FocalApi.TestHelpers

  @create_attrs %{
    event_name: "some event_name",
    shoot_date: "2010-04-17T14:00:00Z",
    uuid: "7488a646-e31f-11e4-aace-600308960662"
  }
  @update_attrs %{
    event_name: "some updated event_name",
    shoot_date: "2011-05-18T15:01:01Z",
    uuid: "7488a646-e31f-11e4-aace-600308960668"
  }
  @invalid_attrs %{event_name: nil, shoot_date: nil, uuid: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index_by_package" do
    setup [:create_event]
    test "lists all events", %{conn: conn, event: event} do
      event = TestHelpers.preloaded_event(event.uuid)

      conn = get(conn, Routes.event_path(conn, :index_by_package, event.package.uuid))
      assert length(json_response(conn, 200)["data"]) == 1
    end
  end

  describe "create event" do
    setup [:create_package]
    test "renders event when data is valid", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      package_client_uuid = package.client.uuid
      package_uuid = package.uuid

      conn = post(conn, Routes.event_path(conn, :create, package.uuid), @create_attrs)
      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.event_path(conn, :show, uuid))

      assert %{
               "event_name" => "some event_name",
               "shoot_date" => "2010-04-17T14:00:00Z",
               "uuid" => uuid,
               "client_uuid" => package_client_uuid,
               "package_uuid" => package_uuid,
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, package: package} do
      conn = post(conn, Routes.event_path(conn, :create, package.uuid), @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update event" do
    setup [:create_event]

    test "renders event when data is valid", %{conn: conn, event: %Event{uuid: uuid} = event} do
      event = TestHelpers.preloaded_event(uuid)
      client_uuid = event.client.uuid
      package_uuid = event.package.uuid

      conn = put(conn, Routes.event_path(conn, :update, uuid), @update_attrs)
      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.event_path(conn, :show, uuid))

      assert %{
               "event_name" => "some updated event_name",
               "shoot_date" => "2011-05-18T15:01:01Z",
               "uuid" => uuid,
               "client_uuid" => package_client_uuid,
               "package_uuid" => package_uuid,
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put(conn, Routes.event_path(conn, :update, event.uuid), @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete event" do
    setup [:create_event]

    test "deletes chosen event", %{conn: conn, event: event} do
      conn = delete(conn, Routes.event_path(conn, :delete, event.uuid))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.event_path(conn, :show, event.uuid))
      end
    end
  end

  defp create_package(_) do
    package = TestHelpers.package_fixture()
    {:ok, package: package}
  end

  defp create_event(_) do
    event = TestHelpers.event_fixture()
    {:ok, event: event}
  end

  defp create_client(_) do
    client = TestHelpers.client_fixture()
    {:ok, client: client}
  end
end
