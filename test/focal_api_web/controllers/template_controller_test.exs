defmodule FocalApiWeb.TemplateControllerTest do
  use FocalApiWeb.ConnCase

  alias FocalApi.Users
  alias FocalApi.Users.Template

  @create_attrs %{
    template_category: "some template_category",
    template_content: "some template_content",
    template_name: "some template_name",
    uuid: "7488a646-e31f-11e4-aace-600308960662"
  }
  @update_attrs %{
    template_category: "some updated template_category",
    template_content: "some updated template_content",
    template_name: "some updated template_name",
    uuid: "7488a646-e31f-11e4-aace-600308960668"
  }
  @invalid_attrs %{template_category: nil, template_content: nil, template_name: nil, uuid: nil}

  def fixture(:template) do
    {:ok, template} = Users.create_template(@create_attrs)
    template
  end

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
    test "renders template when data is valid", %{conn: conn} do
      conn = post(conn, Routes.template_path(conn, :create), template: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.template_path(conn, :show, id))

      assert %{
               "id" => id,
               "template_category" => "some template_category",
               "template_content" => "some template_content",
               "template_name" => "some template_name",
               "uuid" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.template_path(conn, :create), template: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update template" do
    setup [:create_template]

    test "renders template when data is valid", %{conn: conn, template: %Template{id: id} = template} do
      conn = put(conn, Routes.template_path(conn, :update, template), template: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.template_path(conn, :show, id))

      assert %{
               "id" => id,
               "template_category" => "some updated template_category",
               "template_content" => "some updated template_content",
               "template_name" => "some updated template_name",
               "uuid" => "7488a646-e31f-11e4-aace-600308960668"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, template: template} do
      conn = put(conn, Routes.template_path(conn, :update, template), template: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete template" do
    setup [:create_template]

    test "deletes chosen template", %{conn: conn, template: template} do
      conn = delete(conn, Routes.template_path(conn, :delete, template))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.template_path(conn, :show, template))
      end
    end
  end

  defp create_template(_) do
    template = fixture(:template)
    {:ok, template: template}
  end
end
