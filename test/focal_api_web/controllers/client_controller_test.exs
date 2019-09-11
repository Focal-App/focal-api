defmodule FocalApiWeb.ClientControllerTest do
  use FocalApiWeb.ConnCase

  alias FocalApi.Clients
  alias FocalApi.Clients.Client
  alias FocalApi.TestHelpers
  alias FocalApi.Repo

  @create_attrs %{
    client_name: "some client_name",
    uuid: "7488a646-e31f-11e4-aace-600308960662",
  }
  @update_attrs %{
    client_name: "some updated client_name",
    uuid: "7488a646-e31f-11e4-aace-600308960662"
  }
  @invalid_attrs %{client_name: nil, uuid: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "show" do
    setup [:create_client, :create_user]

    test "shows chosen client", %{conn: conn, client: client} do
      client = preloaded_client(client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> get(Routes.client_path(conn, :show, client.uuid))

      assert response(conn, 200)
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, client: client, user: _user} do
      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> get(Routes.client_path(conn, :show, client.uuid))

      assert json_response(conn, 401)["errors"] != %{}
    end

    test "renders error when user is logged in but not authorized to view", %{conn: conn, client: client, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> get(Routes.client_path(conn, :show, client.uuid))

      assert json_response(conn, 403)["errors"] != %{}
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
               "client_name" => "some client_name",
               "uuid" => "7488a646-e31f-11e4-aace-600308960662",
               "user_uuid" => user_uuid
             } = json_response(conn, 200)["data"]
    end

    test "associates the client with the correct user", %{conn: conn, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> post(Routes.client_path(conn, :create), @create_attrs)

      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      client = preloaded_client(uuid)

      assert client.user == user
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> post(Routes.client_path(conn, :create), @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when user is not logged in", %{conn: conn, user: _user} do
      conn = post(conn, Routes.client_path(conn, :create), @create_attrs)

      assert json_response(conn, 401)["errors"] != %{}
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, user: _user} do
      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> post(Routes.client_path(conn, :create), @create_attrs)

      assert json_response(conn, 401)["errors"] != %{}
    end
  end

  describe "update client" do
    setup [:create_client, :create_user]

    test "renders client when data is valid", %{conn: conn, client: %Client{uuid: uuid} = _client} do
      client = preloaded_client(uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> put(Routes.client_path(conn, :update, uuid), @update_attrs)

      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.client_path(conn, :show, uuid))

      assert %{
               "client_name" => "some updated client_name",
               "uuid" => uuid,
               "user_uuid" => client_user_uuid
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, client: client} do
      client = preloaded_client(client.uuid)

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> put(Routes.client_path(conn, :update, client.uuid), @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, client: client, user: _user} do
      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> put(Routes.client_path(conn, :update, client.uuid), @update_attrs)

      assert json_response(conn, 401)["errors"] != %{}
    end

    test "renders error when user is logged in but not authorized to make the change", %{conn: conn, client: client, user: user} do

      conn = conn
      |> TestHelpers.valid_session(user)
      |> put(Routes.client_path(conn, :update, client.uuid), @update_attrs)

      assert json_response(conn, 403)["errors"] != %{}
    end
  end

  describe "delete client" do
    setup [:create_client, :create_user]

    test "deletes chosen client", %{conn: conn, client: client} do
      client = preloaded_client(client.uuid)

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

      assert json_response(conn, 401)["errors"] != %{}
    end

    test "renders error when user is logged in but not authorized to make the change", %{conn: conn, client: client, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> delete(Routes.client_path(conn, :delete, client.uuid))

      assert json_response(conn, 403)["errors"] != %{}
    end
  end

  describe "index_by_user" do
    setup [:create_client, :create_user]
    test "lists all clients for a user", %{conn: conn, client: client} do
      client = preloaded_client(client.uuid)
      user_uuid = client.user.uuid

      conn = conn
      |> TestHelpers.valid_session(client.user)
      |> get(Routes.client_path(conn, :index_by_user, user_uuid))

      assert json_response(conn, 200)["data"] == [%{
        "client_name" => "Snow",
        "user_uuid" => user_uuid,
        "uuid" => client.uuid
      }]
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, client: _client, user: user} do
      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> get(Routes.client_path(conn, :index_by_user, user.uuid))

      assert json_response(conn, 401)["errors"] != %{}
    end

    test "renders error when user is logged in but not authorized to make the change", %{conn: conn, client: client, user: user} do
      client = preloaded_client(client.uuid)
      user_uuid = client.user.uuid

      conn = conn
      |> TestHelpers.valid_session(user)
      |> get(Routes.client_path(conn, :index_by_user, user_uuid))

      assert json_response(conn, 403)["errors"] != %{}
    end
  end


  defp create_client(_) do
    user = TestHelpers.user_fixture()
    client = TestHelpers.client_fixture(%{ user_id: user.id })

    {:ok, client: client}
  end

  defp create_user(_) do
    user = TestHelpers.user_fixture()
    {:ok, user: user}
  end

  defp preloaded_client(uuid) do
    uuid
    |> Clients.get_client_by_uuid!
    |> Repo.preload(:user)
  end
end
