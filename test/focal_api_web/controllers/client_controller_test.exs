defmodule FocalApiWeb.ClientControllerTest do
  use FocalApiWeb.ConnCase

  alias FocalApi.Clients.Client
  alias FocalApi.TestHelpers

  @create_attrs %{
    client_first_name: "some client_name",
    uuid: "7488a646-e31f-11e4-aace-600308960662",
  }
  @update_attrs %{
    client_first_name: "some updated client_name",
    uuid: "7488a646-e31f-11e4-aace-600308960662"
  }
  @invalid_attrs %{client_first_name: nil, uuid: "7488a646-e31f-11e4-aace-600308960662"}
  @invalid_email_attrs %{client_first_name: "snow", client_email: "not an email", uuid: "7488a646-e31f-11e4-aace-600308960662"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "show" do
    setup [:create_client, :create_user]

    test "shows chosen client", %{conn: conn, client: client} do
      client = TestHelpers.preloaded_client(client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> get(Routes.client_path(conn, :show, client.uuid))

      assert response(conn, 200)
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, client: client, user: _user} do
      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> get(Routes.client_path(conn, :show, client.uuid))

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to view", %{conn: conn, client: client, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> get(Routes.client_path(conn, :show, client.uuid))

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end
  end

  describe "show_all_client_data" do
    setup [:create_client, :create_user]

    test "shows all related data for client", %{conn: conn, client: client} do
      client = TestHelpers.preloaded_client(client.uuid)
      package = TestHelpers.package_fixture(%{ client_id: client.id })
      _event1 = TestHelpers.event_fixture(%{ package_id: package.id })
      _event2 = TestHelpers.event_fixture(%{ package_id: package.id })
      _task1 = TestHelpers.task_fixture(%{ client_id: client.id, is_completed: true })
      _task2 = TestHelpers.task_fixture(%{ client_id: client.id, is_completed: false, event_id: nil })

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> get(Routes.client_path(conn, :show_all_client_data, client.uuid))

      assert %{
        "client_first_name" => client_first_name,
        "uuid" => client_uuid,
        "user_uuid" => user_uuid,
        "current_stage" => current_stage,
        "package" => package
      } = json_response(conn, 200)["data"]
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, client: client, user: _user} do
      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> get(Routes.client_path(conn, :show, client.uuid))

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to view", %{conn: conn, client: client, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> get(Routes.client_path(conn, :show, client.uuid))

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end
  end

  describe "index_of_all_client_data_by_user" do
    setup [:create_user]
    test "shows all related data for client", %{conn: conn, user: user} do
      client = TestHelpers.client_fixture(%{ user_id: user.id })
      client = TestHelpers.preloaded_client(client.uuid)
      package = TestHelpers.package_fixture(%{ client_id: client.id })
      _event1 = TestHelpers.event_fixture(%{ package_id: package.id })
      _event2 = TestHelpers.event_fixture(%{ package_id: package.id })
      _task1 = TestHelpers.task_fixture(%{ client_id: client.id, is_completed: true })
      _task2 = TestHelpers.task_fixture(%{ client_id: client.id, is_completed: false, event_id: nil })

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> get(Routes.client_path(conn, :index_of_all_client_data_by_user, user.uuid))

      assert [%{
        "client_first_name" => client_first_name,
        "partner_first_name" => partner_first_name,
        "package_name" => package_name,
        "upcoming_shoot_date" => upcoming_shoot_date,
        "current_stage" => current_stage,
        "uuid" => client_uuid,
      }] = json_response(conn, 200)["data"]
    end
  end

  describe "create client" do
    setup [:create_user]
    test "renders client when data is valid", %{conn: conn, user: user} do
      _user_uuid = user.uuid
      conn = conn
      |> TestHelpers.valid_session(user)
      |> post(Routes.client_path(conn, :create), @create_attrs)

      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.client_path(conn, :show, uuid))

      assert %{
               "client_first_name" => "some client_name",
               "uuid" => "7488a646-e31f-11e4-aace-600308960662",
               "user_uuid" => user_uuid
             } = json_response(conn, 200)["data"]
    end

    test "associates the client with the correct user", %{conn: conn, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> post(Routes.client_path(conn, :create), @create_attrs)

      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      client = TestHelpers.preloaded_client(uuid)

      assert client.user == user
    end

    test "renders errors when data is invalid (missing client_first_name)", %{conn: conn, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> post(Routes.client_path(conn, :create), @invalid_attrs)

      assert json_response(conn, 422)["errors"] == %{"client_first_name" => ["can't be blank"]}
    end

    test "renders errors when data is invalid (client_email not an email)", %{conn: conn, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> post(Routes.client_path(conn, :create), @invalid_email_attrs)

      assert json_response(conn, 422)["errors"] == %{"client_email" => ["has invalid format"]}
    end

    test "renders error when user is not logged in", %{conn: conn, user: _user} do
      conn = post(conn, Routes.client_path(conn, :create), @create_attrs)

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, user: _user} do
      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> post(Routes.client_path(conn, :create), @create_attrs)

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end
  end

  describe "update client" do
    setup [:create_client, :create_user]

    test "renders client when data is valid", %{conn: conn, client: %Client{uuid: uuid} = _client} do
      client = TestHelpers.preloaded_client(uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> put(Routes.client_path(conn, :update, uuid), @update_attrs)

      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.client_path(conn, :show, uuid))

      assert %{
               "client_first_name" => "some updated client_name",
               "uuid" => uuid,
               "user_uuid" => client_user_uuid
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, client: client} do
      client = TestHelpers.preloaded_client(client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> put(Routes.client_path(conn, :update, client.uuid), @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, client: client, user: _user} do
      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> put(Routes.client_path(conn, :update, client.uuid), @update_attrs)

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to make the change", %{conn: conn, client: client, user: user} do

      conn = conn
      |> TestHelpers.valid_session(user)
      |> put(Routes.client_path(conn, :update, client.uuid), @update_attrs)

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end
  end

  describe "delete client" do
    setup [:create_client, :create_user]

    test "deletes chosen client", %{conn: conn, client: client} do
      client = TestHelpers.preloaded_client(client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> delete(Routes.client_path(conn, :delete, client.uuid))

      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.client_path(conn, :show, client.uuid))
      end
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, client: client, user: _user} do
      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> delete(Routes.client_path(conn, :delete, client.uuid))

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but not authorized to make the change", %{conn: conn, client: client, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> delete(Routes.client_path(conn, :delete, client.uuid))

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end
  end

  describe "index_by_user" do
    setup [:create_client, :create_user]
    test "lists all clients for a user", %{conn: conn, client: client} do
      client = TestHelpers.preloaded_client(client.uuid)
      user_uuid = client.user.uuid

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> get(Routes.client_path(conn, :index_by_user, user_uuid))

      assert json_response(conn, 200)["data"] == [%{
        "client_first_name" => "Snow",
        "user_uuid" => user_uuid,
        "uuid" => client.uuid,
        "client_email" => nil,
        "client_last_name" => nil,
        "client_phone_number" => nil,
        "private_notes" => nil
      }]
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, client: _client, user: user} do
      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> get(Routes.client_path(conn, :index_by_user, user.uuid))

      assert json_response(conn, 401)["errors"] != %{}
    end

    test "renders error when user is logged in but not authorized to make the change", %{conn: conn, client: client, user: user} do
      client = TestHelpers.preloaded_client(client.uuid)
      user_uuid = client.user.uuid

      conn = conn
      |> TestHelpers.valid_session(user)
      |> get(Routes.client_path(conn, :index_by_user, user_uuid))

      assert json_response(conn, 403)["errors"] != %{}
    end
  end


  defp create_client(_) do
    client = TestHelpers.client_fixture()
    {:ok, client: client}
  end

  defp create_user(_) do
    user = TestHelpers.user_fixture()
    {:ok, user: user}
  end
end
