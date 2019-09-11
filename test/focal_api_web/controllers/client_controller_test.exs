defmodule FocalApiWeb.ClientControllerTest do
  use FocalApiWeb.ConnCase

  alias FocalApi.Clients
  alias FocalApi.Clients.Client
  alias FocalApi.TestHelpers

  @create_attrs %{
    client_name: "some client_name",
    uuid: "7488a646-e31f-11e4-aace-600308960662"
  }
  @update_attrs %{
    client_name: "some updated client_name",
    uuid: "7488a646-e31f-11e4-aace-600308960662"
  }
  @invalid_attrs %{client_name: nil, uuid: nil}

  def fixture(:client) do
    {:ok, client} = Clients.create_client(@create_attrs)
    client
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all clients", %{conn: conn} do
      conn = get(conn, Routes.client_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create client" do
    setup [:create_user]
    test "renders client when data is valid", %{conn: conn, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> post(Routes.client_path(conn, :create), client: @create_attrs)

      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.client_path(conn, :show, uuid))

      assert %{
               "client_name" => "some client_name",
               "uuid" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> post(Routes.client_path(conn, :create), client: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when user is not logged in", %{conn: conn, user: _user} do
      conn = post(conn, Routes.client_path(conn, :create, client: @create_attrs))

      assert json_response(conn, 401)["errors"] != %{}
  end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, user: _user} do
      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> post(Routes.client_path(conn, :create), client: @create_attrs)

      assert json_response(conn, 401)["errors"] != %{}
    end
  end

  describe "update client" do
    setup [:create_client, :create_user]

    test "renders client when data is valid", %{conn: conn, client: %Client{uuid: uuid} = _client, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> put(Routes.client_path(conn, :update, uuid), @update_attrs)

      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.client_path(conn, :show, uuid))

      assert %{
               "client_name" => "some updated client_name",
               "uuid" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, client: client, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> put(Routes.client_path(conn, :update, client.uuid), @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when user is logged in but request is not authenticated", %{conn: conn, client: client, user: _user} do
      conn = conn
      |> TestHelpers.invalid_session("test_id_token")
      |> put(Routes.client_path(conn, :update, client.uuid), @update_attrs)

      assert json_response(conn, 401)["errors"] != %{}
    end

  end

  describe "delete client" do
    setup [:create_client, :create_user]

    test "deletes chosen client", %{conn: conn, client: client, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
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
  end

  defp create_client(_) do
    client = fixture(:client)
    {:ok, client: client}
  end

  defp create_user(_) do
    user = TestHelpers.user_fixture()
    {:ok, user: user}
  end
end
