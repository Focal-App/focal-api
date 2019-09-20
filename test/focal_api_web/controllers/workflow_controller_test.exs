defmodule FocalApiWeb.WorkflowControllerTest do
  use FocalApiWeb.ConnCase

  alias FocalApi.Clients.Workflow
  alias FocalApi.TestHelpers

  @create_attrs %{
    uuid: "7488a646-e31f-11e4-aace-600308960662",
    workflow_name: "some workflow_name"
  }
  @update_attrs %{
    uuid: "7488a646-e31f-11e4-aace-600308960668",
    workflow_name: "some updated workflow_name"
  }
  @invalid_attrs %{uuid: nil, workflow_name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index_by_client" do
    setup [:create_workflow]
    test "lists all workflows for client", %{conn: conn, workflow: workflow} do
      workflow = TestHelpers.preloaded_workflow(workflow.uuid)
      client = TestHelpers.preloaded_client(workflow.client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> get(Routes.workflow_path(conn, :index_by_client, workflow.client.uuid))

      assert length(json_response(conn, 200)["data"]) == 1
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, workflow: workflow} do
      workflow = TestHelpers.preloaded_workflow(workflow.uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> get(Routes.workflow_path(conn, :index_by_client, workflow.client.uuid))

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to view", %{conn: conn, workflow: workflow} do
      workflow = TestHelpers.preloaded_workflow(workflow.uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> get(Routes.workflow_path(conn, :index_by_client, workflow.client.uuid))

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end
  end

  describe "create workflow" do
    setup [:create_client]
    test "renders workflow when data is valid", %{conn: conn, client: client} do
      client = TestHelpers.preloaded_client(client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> post(Routes.workflow_path(conn, :create, client.uuid), @create_attrs)

      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.workflow_path(conn, :show, uuid))

      assert %{
               "uuid" => uuid,
               "workflow_name" => "some workflow_name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, client: client} do
      client = TestHelpers.preloaded_client(client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> post(Routes.workflow_path(conn, :create, client.uuid), @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, client: client} do
      client_uuid = client.uuid
      client = TestHelpers.preloaded_client(client_uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> post(Routes.workflow_path(conn, :create, client.uuid), @invalid_attrs)

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to create", %{conn: conn, client: client} do
      client_uuid = client.uuid
      client = TestHelpers.preloaded_client(client_uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> post(Routes.workflow_path(conn, :create, client.uuid), @invalid_attrs)

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end
  end

  describe "update workflow" do
    setup [:create_workflow]

    test "renders workflow when data is valid", %{conn: conn, workflow: %Workflow{uuid: uuid} = workflow} do
      workflow = TestHelpers.preloaded_workflow(workflow.uuid)
      client = TestHelpers.preloaded_client(workflow.client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> put(Routes.workflow_path(conn, :update, uuid), @update_attrs)

      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workflow_path(conn, :show, uuid))

      assert %{
               "uuid" => uuid,
               "workflow_name" => "some updated workflow_name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, workflow: workflow} do
      workflow = TestHelpers.preloaded_workflow(workflow.uuid)
      client = TestHelpers.preloaded_client(workflow.client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> put(Routes.workflow_path(conn, :update, workflow.uuid), @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, workflow: workflow} do
      workflow = TestHelpers.preloaded_workflow(workflow.uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> put(Routes.workflow_path(conn, :update, workflow.uuid), @invalid_attrs)

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to update", %{conn: conn, workflow: workflow} do
      workflow = TestHelpers.preloaded_workflow(workflow.uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> put(Routes.workflow_path(conn, :update, workflow.uuid), @invalid_attrs)

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end
  end

  describe "delete workflow" do
    setup [:create_workflow]

    test "deletes chosen workflow", %{conn: conn, workflow: workflow} do
      workflow = TestHelpers.preloaded_workflow(workflow.uuid)
      client = TestHelpers.preloaded_client(workflow.client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> delete(Routes.workflow_path(conn, :delete, workflow.uuid))

      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.workflow_path(conn, :show, workflow.uuid))
      end
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, workflow: workflow} do
      workflow = TestHelpers.preloaded_workflow(workflow.uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> delete(Routes.workflow_path(conn, :delete, workflow.uuid))

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to delete", %{conn: conn, workflow: workflow} do
      workflow = TestHelpers.preloaded_workflow(workflow.uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> delete(Routes.workflow_path(conn, :delete, workflow.uuid))

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end
  end

  defp create_workflow(_) do
    workflow = TestHelpers.workflow_fixture()
    {:ok, workflow: workflow}
  end

  defp create_client(_) do
    client = TestHelpers.client_fixture()
    {:ok, client: client}
  end
end
