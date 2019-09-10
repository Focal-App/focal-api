defmodule FocalApiWeb.ClientControllerTest do
  use FocalApiWeb.ConnCase

  alias FocalApi.Clients
  alias FocalApi.Clients.Client

  @create_attrs %{
    client_name: "some client_name",
    uuid: "7488a646-e31f-11e4-aace-600308960662"
  }
  @update_attrs %{
    client_name: "some updated client_name",
    uuid: "7488a646-e31f-11e4-aace-600308960662"
  }
  @invalid_attrs %{client_name: nil, uuid: nil}
  @uuid Ecto.UUID.generate()

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
    test "renders client when data is valid", %{conn: conn} do
      conn = post(conn, Routes.client_path(conn, :create), client: @create_attrs)
      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.client_path(conn, :show, uuid))

      assert %{
               "id" => id,
               "client_name" => "some client_name",
               "uuid" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.client_path(conn, :create), client: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update client" do
    setup [:create_client]

    test "renders client when data is valid", %{conn: conn, client: %Client{uuid: uuid} = client} do
      conn = put(conn, Routes.client_path(conn, :update, uuid), @update_attrs)
      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.client_path(conn, :show, uuid))

      assert %{
               "id" => id,
               "client_name" => "some updated client_name",
               "uuid" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, client: client} do
      conn = put(conn, Routes.client_path(conn, :update, client.uuid), @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete client" do
    setup [:create_client]

    test "deletes chosen client", %{conn: conn, client: client} do
      conn = delete(conn, Routes.client_path(conn, :delete, client.uuid))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.client_path(conn, :show, client.uuid))
      end
    end
  end

  defp create_client(_) do
    client = fixture(:client)
    {:ok, client: client}
  end
end
