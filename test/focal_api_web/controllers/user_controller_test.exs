defmodule FocalApiWeb.UserControllerTest do
  use FocalApiWeb.ConnCase

  alias FocalApi.Accounts
  alias FocalApi.Accounts.User

  @id 1
  @create_attrs %{
    avatar: "some avatar",
    email: "some email",
    first_name: "some first_name",
    provider: "some provider",
    uuid: "7488a646-e31f-11e4-aace-600308960662",
    id: @id,
    google_id: "1234",
    google_refresh_token: "1234"
  }
  @invalid_attrs %{
    avatar: nil,
    email: nil,
    first_name: nil,
    provider: nil,
    uuid: nil,
    google_id: nil,
    google_refresh_token: nil
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "show" do
    setup [:create_user]

    test "shows a users", %{conn: conn, user: %User{uuid: uuid} = _user} do
      conn = get(conn, Routes.user_path(conn, :show, uuid))

      assert json_response(conn, 200)["data"] == %{
               "avatar" => "some avatar",
               "email" => "some email",
               "first_name" => "some first_name",
               "provider" => "some provider",
               "uuid" => "7488a646-e31f-11e4-aace-600308960662"
             }
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, uuid))

      assert %{
               "avatar" => "some avatar",
               "email" => "some email",
               "first_name" => "some first_name",
               "provider" => "some provider",
               "uuid" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
