defmodule FocalApiWeb.TaskControllerTest do
  use FocalApiWeb.ConnCase

  alias FocalApi.Clients.Task
  alias FocalApi.TestHelpers

  @create_attrs %{
    category: "some category",
    is_completed: true,
    step: "some step",
    uuid: "7488a646-e31f-11e4-aace-600308960662"
  }
  @update_attrs %{
    category: "some updated category",
    is_completed: false,
    step: "some updated step",
    uuid: "7488a646-e31f-11e4-aace-600308960668"
  }
  @invalid_attrs %{category: nil, is_completed: nil, step: nil, uuid: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index_by_client" do
    setup [:create_task]
    test "lists all tasks by client", %{conn: conn, task: task} do
      task = TestHelpers.preloaded_task(task.uuid)
      client = TestHelpers.preloaded_client(task.client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> get(Routes.task_path(conn, :index_by_client, task.client.uuid))

      assert length(json_response(conn, 200)["data"]) == 1
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, task: task} do
      task = TestHelpers.preloaded_task(task.uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> get(Routes.task_path(conn, :index_by_client, task.client.uuid))

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to view", %{conn: conn, task: task} do
      task = TestHelpers.preloaded_task(task.uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> get(Routes.task_path(conn, :index_by_client, task.client.uuid))

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end
  end

  describe "create task" do
    setup [:create_client]
    test "renders task when data is valid", %{conn: conn, client: client} do
      client = TestHelpers.preloaded_client(client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> post(Routes.task_path(conn, :create, client.uuid), @create_attrs)

      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.task_path(conn, :show, uuid))

      assert %{
               "category" => "some category",
               "is_completed" => true,
               "step" => "some step",
               "uuid" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, client: client} do
      client = TestHelpers.preloaded_client(client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> post(Routes.task_path(conn, :create, client.uuid), @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, client: client} do
      client = TestHelpers.preloaded_client(client.uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> post(Routes.task_path(conn, :create, client.uuid), @invalid_attrs)

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to create", %{conn: conn, client: client} do
      client = TestHelpers.preloaded_client(client.uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> post(Routes.task_path(conn, :create, client.uuid), @invalid_attrs)

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end
  end

  describe "update task" do
    setup [:create_task]

    test "renders task when data is valid", %{conn: conn, task: %Task{uuid: uuid} = _task} do
      task = TestHelpers.preloaded_task(uuid)
      client = TestHelpers.preloaded_client(task.client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> put(Routes.task_path(conn, :update, uuid), @update_attrs)

      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.task_path(conn, :show, uuid))

      assert %{
               "category" => "some updated category",
               "is_completed" => false,
               "step" => "some updated step",
               "uuid" => uuid,
               "client_uuid" => task_client_uuid,
                "event_uuid" => task_event_uuid,
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, task: task} do
      task = TestHelpers.preloaded_task(task.uuid)
      client = TestHelpers.preloaded_client(task.client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> put(Routes.task_path(conn, :update, task.uuid), @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, task: task} do
      task = TestHelpers.preloaded_task(task.uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> put(Routes.task_path(conn, :update, task.uuid), @invalid_attrs)

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to update", %{conn: conn, task: task} do
      task = TestHelpers.preloaded_task(task.uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> put(Routes.task_path(conn, :update, task.uuid), @invalid_attrs)

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end
  end

  describe "delete task" do
    setup [:create_task]

    test "deletes chosen task", %{conn: conn, task: task} do
      task = TestHelpers.preloaded_task(task.uuid)
      client = TestHelpers.preloaded_client(task.client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> delete(Routes.task_path(conn, :delete, task.uuid))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.task_path(conn, :show, task.uuid))
      end
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, task: task} do
      task = TestHelpers.preloaded_task(task.uuid)

      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> delete(Routes.task_path(conn, :delete, task.uuid))

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to delete", %{conn: conn, task: task} do
      task = TestHelpers.preloaded_task(task.uuid)

      conn = conn
      |> TestHelpers.valid_session(TestHelpers.user_fixture())
      |> delete(Routes.task_path(conn, :delete, task.uuid))

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end
  end

  defp create_task(_) do
    task = TestHelpers.task_fixture()
    {:ok, task: task}
  end

  defp create_client(_) do
    client = TestHelpers.client_fixture()
    {:ok, client: client}
  end
end
