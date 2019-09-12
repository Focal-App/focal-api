defmodule FocalApiWeb.PackageControllerTest do
  use FocalApiWeb.ConnCase

  alias FocalApi.Clients
  alias FocalApi.Clients.Package
  alias FocalApi.TestHelpers
  alias FocalApi.Repo

  @create_attrs %{
    package_name: "some package_name",
    uuid: "7488a646-e31f-11e4-aace-600308960662"
  }
  @update_attrs %{
    package_name: "some updated package_name",
    uuid: "7488a646-e31f-11e4-aace-600308960668"
  }
  @invalid_attrs %{package_name: nil, uuid: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_client]
    test "lists all packages", %{conn: conn, client: client} do
      conn = get(conn, Routes.package_path(conn, :index, client.uuid))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create package" do
    setup [:create_client]
    test "renders package when data is valid", %{conn: conn, client: client} do
      client_uuid = client.uuid
      conn = post(conn, Routes.package_path(conn, :create, client_uuid), @create_attrs)
      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.package_path(conn, :show, client.uuid, uuid))

      assert %{
               "package_name" => "some package_name",
               "uuid" => uuid,
               "client_uuid" => client_uuid
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, client: client} do
      conn = post(conn, Routes.package_path(conn, :create, client.uuid), @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update package" do
    setup [:create_package]

    test "renders package when data is valid", %{conn: conn, package: %Package{uuid: uuid} = _package} do
      package = preloaded_package(uuid)
      package_client_uuid = package.client.uuid

      conn = put(conn, Routes.package_path(conn, :update, package_client_uuid, package.uuid), @update_attrs)
      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.package_path(conn, :show, package_client_uuid, uuid))

      assert %{
               "package_name" => "some updated package_name",
               "uuid" => uuid,
               "client_uuid" => package_client_uuid
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, package: package} do
      package = preloaded_package(package.uuid)
      package_client_uuid = package.client.uuid

      conn = put(conn, Routes.package_path(conn, :update, package_client_uuid, package.uuid), @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete package" do
    setup [:create_package]

    test "deletes chosen package", %{conn: conn, package: package} do
      package = preloaded_package(package.uuid)
      package_client_uuid = package.client.uuid

      conn = delete(conn, Routes.package_path(conn, :delete, package_client_uuid, package.uuid))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.package_path(conn, :show, package_client_uuid, package.uuid))
      end
    end
  end

  defp create_package(_) do
    package = TestHelpers.package_fixture()
    {:ok, package: package}
  end

  defp create_client(_) do
    user = TestHelpers.user_fixture()
    client = TestHelpers.client_fixture(%{ user_id: user.id })

    {:ok, client: client}
  end

  defp preloaded_package(uuid) do
    uuid
    |> Clients.get_package_by_uuid!
    |> Repo.preload(:client)
  end
end
