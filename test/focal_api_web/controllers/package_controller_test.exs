defmodule FocalApiWeb.PackageControllerTest do
  use FocalApiWeb.ConnCase

  alias FocalApi.Clients.Package
  alias FocalApi.TestHelpers

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
    setup [:create_package]
    test "lists all packages", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      client = TestHelpers.preloaded_client(package.client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> get(Routes.package_path(conn, :index, client.uuid))

      assert length(json_response(conn, 200)["data"]) == 1
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      client = TestHelpers.preloaded_client(package.client.uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> get(Routes.package_path(conn, :index, client.uuid))

      assert json_response(conn, 401)["errors"] != %{}
    end

    test "renders error when user is logged in but not authorized to view", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      client = TestHelpers.preloaded_client(package.client.uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> get(Routes.package_path(conn, :index, client.uuid))

      assert json_response(conn, 403)["errors"] != %{}
    end
  end

  describe "show" do
    setup [:create_package]

    test "shows chosen package", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      client = TestHelpers.preloaded_client(package.client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> get(Routes.package_path(conn, :show, client.uuid, package.uuid))

      assert response(conn, 200)
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      client = TestHelpers.preloaded_client(package.client.uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> get(Routes.package_path(conn, :show, client.uuid, package.uuid))

      assert json_response(conn, 401)["errors"] != %{}
    end

    test "renders error when user is logged in but not authorized to view", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      client = TestHelpers.preloaded_client(package.client.uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> get(Routes.package_path(conn, :show, client.uuid, package.uuid))

      assert json_response(conn, 403)["errors"] != %{}
    end
  end

  describe "create package" do
    setup [:create_client]
    test "renders package when data is valid", %{conn: conn, client: client} do
      client_uuid = client.uuid
      client = TestHelpers.preloaded_client(client_uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> post(Routes.package_path(conn, :create, client_uuid), @create_attrs)

      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.package_path(conn, :show, client.uuid, uuid))

      assert %{
               "package_name" => "some package_name",
               "uuid" => uuid,
               "client_uuid" => client_uuid
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, client: client} do
      client_uuid = client.uuid
      client = TestHelpers.preloaded_client(client_uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |>  post(Routes.package_path(conn, :create, client.uuid), @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, client: client} do
      client_uuid = client.uuid
      client = TestHelpers.preloaded_client(client_uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> post(Routes.package_path(conn, :create, client.uuid), @invalid_attrs)

      assert json_response(conn, 401)["errors"] != %{}
    end

    test "renders error when user is logged in but not authorized to create", %{conn: conn, client: client} do
      client_uuid = client.uuid
      client = TestHelpers.preloaded_client(client_uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> post(Routes.package_path(conn, :create, client.uuid), @invalid_attrs)

      assert json_response(conn, 403)["errors"] != %{}
    end
  end

  describe "update package" do
    setup [:create_package]

    test "renders package when data is valid", %{conn: conn, package: %Package{uuid: uuid} = _package} do
      package = TestHelpers.preloaded_package(uuid)
      package_client_uuid = package.client.uuid
      client = TestHelpers.preloaded_client(package_client_uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> put(Routes.package_path(conn, :update, package_client_uuid, package.uuid), @update_attrs)

      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.package_path(conn, :show, package_client_uuid, uuid))

      assert %{
               "package_name" => "some updated package_name",
               "uuid" => uuid,
               "client_uuid" => package_client_uuid
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      package_client_uuid = package.client.uuid
      client = TestHelpers.preloaded_client(package_client_uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> put(Routes.package_path(conn, :update, package_client_uuid, package.uuid), @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      package_client_uuid = package.client.uuid

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> put(Routes.package_path(conn, :update, package_client_uuid, package.uuid), @invalid_attrs)

      assert json_response(conn, 401)["errors"] != %{}
    end

    test "renders error when user is logged in but not authorized to update", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      package_client_uuid = package.client.uuid

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> put(Routes.package_path(conn, :update, package_client_uuid, package.uuid), @invalid_attrs)

      assert json_response(conn, 403)["errors"] != %{}
    end
  end

  describe "delete package" do
    setup [:create_package]

    test "deletes chosen package", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      package_client_uuid = package.client.uuid
      client = TestHelpers.preloaded_client(package_client_uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> delete(Routes.package_path(conn, :delete, package_client_uuid, package.uuid))

      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.package_path(conn, :show, package_client_uuid, package.uuid))
      end
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      package_client_uuid = package.client.uuid

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> delete(Routes.package_path(conn, :delete, package_client_uuid, package.uuid))

      assert json_response(conn, 401)["errors"] != %{}
    end

    test "renders error when user is logged in but not authorized to delete", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      package_client_uuid = package.client.uuid

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> delete(Routes.package_path(conn, :delete, package_client_uuid, package.uuid))

      assert json_response(conn, 403)["errors"] != %{}
    end
  end

  defp create_package(_) do
    package = TestHelpers.package_fixture()
    {:ok, package: package}
  end

  defp create_client(_) do
    client = TestHelpers.client_fixture()
    {:ok, client: client}
  end
end
