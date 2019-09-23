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

  describe "index_by_client" do
    setup [:create_package]
    test "lists all packages", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      client = TestHelpers.preloaded_client(package.client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> get(Routes.package_path(conn, :index_by_client, client.uuid))

      assert length(json_response(conn, 200)["data"]) == 1
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      client = TestHelpers.preloaded_client(package.client.uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> get(Routes.package_path(conn, :index_by_client, client.uuid))

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to view", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      client = TestHelpers.preloaded_client(package.client.uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> get(Routes.package_path(conn, :index_by_client, client.uuid))

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end
  end

  describe "show" do
    setup [:create_package]

    test "shows chosen package", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      client = TestHelpers.preloaded_client(package.client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> get(Routes.package_path(conn, :show, package.uuid))

      assert response(conn, 200)
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> get(Routes.package_path(conn, :show, package.uuid))

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to view", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> get(Routes.package_path(conn, :show, package.uuid))

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end
  end

  describe "create package" do
    setup [:create_client]
    test "renders package when data is valid", %{conn: conn, client: client} do
      client_uuid = client.uuid
      client = TestHelpers.preloaded_client(client_uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> post(Routes.package_path(conn, :create, client.uuid), @create_attrs)

      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.package_path(conn, :show, uuid))

      assert %{
                "package_name" => "some package_name",
                "uuid" => uuid,
                "client_uuid" => client_uuid,
                "proposal_signed" => proposal_signed,
                "package_contents" => package_contents,
                "package_price" => package_price,
                "retainer_price" => retainer_price,
                "retainer_paid_amount" => retainer_paid_amount,
                "retainer_paid" => retainer_paid,
                "discount_offered" => discount_offered,
                "balance_remaining" => balance_remaining,
                "balance_received" => balance_received,
                "wedding_included" => wedding_included,
                "engagement_included" => engagement_included,
             } = json_response(conn, 200)["data"]
    end

    test "associates the client with engagement, wedding and closeout workflows if package includes wedding and engagement", %{conn: conn, client: client} do
      client = TestHelpers.preloaded_client(client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> post(Routes.package_path(conn, :create, client.uuid), %{
        package_name: "some package_name",
        uuid: "7488a646-e31f-11e4-aace-600308960662",
        wedding_included: true,
        engagement_included: true
      })

      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.workflow_path(conn, :index_by_client, client.uuid))

      assert length(json_response(conn, 200)["data"]) == 3

      conn = get(conn, Routes.task_path(conn, :index_by_client, client.uuid))

      assert length(json_response(conn, 200)["data"]) == 23
    end

    test "associates the client with engagement and closeout workflows if package includes only engagement", %{conn: conn, client: client} do
      client = TestHelpers.preloaded_client(client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> post(Routes.package_path(conn, :create, client.uuid), %{
        package_name: "some package_name",
        uuid: "7488a646-e31f-11e4-aace-600308960662",
        wedding_included: false,
        engagement_included: true
      })

      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.workflow_path(conn, :index_by_client, client.uuid))

      assert length(json_response(conn, 200)["data"]) == 2

      conn = get(conn, Routes.task_path(conn, :index_by_client, client.uuid))

      assert length(json_response(conn, 200)["data"]) == 13
    end

    test "renders errors when data is invalid", %{conn: conn, client: client} do
      client_uuid = client.uuid
      client = TestHelpers.preloaded_client(client_uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> post(Routes.package_path(conn, :create, client.uuid), @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, client: client} do
      client_uuid = client.uuid
      client = TestHelpers.preloaded_client(client_uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> post(Routes.package_path(conn, :create, client.uuid), @invalid_attrs)

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to create", %{conn: conn, client: client} do
      client_uuid = client.uuid
      client = TestHelpers.preloaded_client(client_uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> post(Routes.package_path(conn, :create, client.uuid), @invalid_attrs)

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
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
      |> put(Routes.package_path(conn, :update, package.uuid), @update_attrs)

      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.package_path(conn, :show, uuid))

      assert %{
               "package_name" => "some updated package_name",
               "uuid" => uuid,
               "client_uuid" => package_client_uuid,
               "proposal_signed" => proposal_signed,
                "package_contents" => package_contents,
                "package_price" => package_price,
                "retainer_price" => retainer_price,
                "retainer_paid_amount" => retainer_paid_amount,
                "retainer_paid" => retainer_paid,
                "discount_offered" => discount_offered,
                "balance_remaining" => balance_remaining,
                "balance_received" => balance_received,
             } = json_response(conn, 200)["data"]
    end

    test "associates the client with engagement, wedding workflows if package update includes wedding and engagement", %{conn: conn, package: %Package{uuid: uuid} = _package} do
      package = TestHelpers.preloaded_package(uuid)
      package_client_uuid = package.client.uuid
      client = TestHelpers.preloaded_client(package_client_uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> put(Routes.package_path(conn, :update, package.uuid), %{
        package_name: "some updated package_name",
        uuid: "7488a646-e31f-11e4-aace-600308960668",
        wedding_included: true,
        engagement_included: true
      })

      assert %{"uuid" => uuid} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workflow_path(conn, :index_by_client, client.uuid))

      assert length(json_response(conn, 200)["data"]) == 2

      conn = get(conn, Routes.task_path(conn, :index_by_client, client.uuid))

      assert length(json_response(conn, 200)["data"]) == 18

      conn = conn
      |> put(Routes.package_path(conn, :update, package.uuid), %{
        package_name: "some updated package_name",
        uuid: "7488a646-e31f-11e4-aace-600308960668",
        wedding_included: true,
        engagement_included: true
      })

      assert %{"uuid" => uuid} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workflow_path(conn, :index_by_client, client.uuid))

      assert length(json_response(conn, 200)["data"]) == 2

      conn = get(conn, Routes.task_path(conn, :index_by_client, client.uuid))

      assert length(json_response(conn, 200)["data"]) == 18
    end

    test "removes client engagement and wedding workflows if package update does not include wedding and engagement", %{conn: conn, package: %Package{uuid: uuid} = _package} do
      package = TestHelpers.preloaded_package(uuid)
      package_client_uuid = package.client.uuid
      client = TestHelpers.preloaded_client(package_client_uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> put(Routes.package_path(conn, :update, package.uuid), %{
        package_name: "some updated package_name",
        uuid: "7488a646-e31f-11e4-aace-600308960668",
        wedding_included: true,
        engagement_included: true
      })

      assert %{"uuid" => uuid} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workflow_path(conn, :index_by_client, client.uuid))

      assert length(json_response(conn, 200)["data"]) == 2

      conn = get(conn, Routes.task_path(conn, :index_by_client, client.uuid))

      assert length(json_response(conn, 200)["data"]) == 18

      conn = conn
      |> put(Routes.package_path(conn, :update, package.uuid), %{
        package_name: "some updated package_name",
        uuid: "7488a646-e31f-11e4-aace-600308960668",
        wedding_included: false,
        engagement_included: false
      })

      assert %{"uuid" => uuid} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workflow_path(conn, :index_by_client, client.uuid))

      assert length(json_response(conn, 200)["data"]) == 0

      conn = get(conn, Routes.task_path(conn, :index_by_client, client.uuid))

      assert length(json_response(conn, 200)["data"]) == 0
    end

    test "renders errors when data is invalid", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)
      package_client_uuid = package.client.uuid
      client = TestHelpers.preloaded_client(package_client_uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> put(Routes.package_path(conn, :update, package.uuid), @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> put(Routes.package_path(conn, :update, package.uuid), @invalid_attrs)

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to update", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> put(Routes.package_path(conn, :update, package.uuid), @invalid_attrs)

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
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
      |> delete(Routes.package_path(conn, :delete, package.uuid))

      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.package_path(conn, :show, package.uuid))
      end
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> delete(Routes.package_path(conn, :delete, package.uuid))

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to delete", %{conn: conn, package: package} do
      package = TestHelpers.preloaded_package(package.uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> delete(Routes.package_path(conn, :delete, package.uuid))

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
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
