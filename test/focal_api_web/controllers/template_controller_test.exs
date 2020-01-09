defmodule FocalApiWeb.TemplateControllerTest do
  use FocalApiWeb.ConnCase

  alias FocalApi.Users
  alias FocalApi.Users.Template
  alias FocalApi.TestHelpers

  @create_attrs %{
    template_category: "some template_category",
    template_content: "some template_content",
    template_name: "some template_name",
  }
  @update_attrs %{
    template_category: "some updated template_category",
    template_content: "some updated template_content",
    template_name: "some updated template_name",
  }
  @invalid_attrs %{template_category: nil, template_content: nil, template_name: nil, uuid: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all templates", %{conn: conn} do
      conn = get(conn, Routes.template_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create template" do
    setup [:create_user]

    test "renders template when data is valid", %{conn: conn, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> post(Routes.template_path(conn, :create), template: @create_attrs)

      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.template_path(conn, :show, uuid))

      assert %{
               "user_uuid" => user_uuid,
               "updated_at" => updated_at,
               "template_category" => "some template_category",
               "template_content" => "some template_content",
               "template_name" => "some template_name",
               "uuid" => uuid
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> post(Routes.template_path(conn, :create), template: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when user is not logged in", %{conn: conn, user: _user} do
      conn = post(conn, Routes.template_path(conn, :create), template: @create_attrs)


      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

  end

  describe "update template" do
    setup [:create_template, :create_user]

    test "renders template when data is valid", %{conn: conn, template: %Template{uuid: uuid} = template, user: user} do
      user_uuid = user.uuid
      conn = conn
      |> TestHelpers.valid_session(user)
      |> put(Routes.template_path(conn, :update, uuid), template: @update_attrs)

      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.template_path(conn, :show, uuid))

      assert %{
               "template_category" => "some updated template_category",
               "template_content" => "some updated template_content",
               "template_name" => "some updated template_name",
               "uuid" => user_uuid
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, template: template, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> put(Routes.template_path(conn, :update, template.uuid), template: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete template" do
    setup [:create_template, :create_user]

    test "deletes chosen template", %{conn: conn, template: template, user: user} do
      conn = conn
      |> TestHelpers.valid_session(user)
      |> delete(Routes.template_path(conn, :delete, template.uuid))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.template_path(conn, :show, template.uuid))
      end
    end
  end

  defp create_template(_) do
    template = TestHelpers.template_fixture()
    {:ok, template: template}
  end

  defp create_user(_) do
    user = TestHelpers.user_fixture()
    {:ok, user: user}
  end
end
