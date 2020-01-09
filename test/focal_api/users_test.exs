defmodule FocalApi.UsersTest do
  use FocalApi.DataCase

  alias FocalApi.Users

  describe "templates" do
    alias FocalApi.Users.Template

    @valid_attrs %{template_category: "some template_category", template_content: "some template_content", template_name: "some template_name", uuid: "7488a646-e31f-11e4-aace-600308960662"}
    @update_attrs %{template_category: "some updated template_category", template_content: "some updated template_content", template_name: "some updated template_name", uuid: "7488a646-e31f-11e4-aace-600308960668"}
    @invalid_attrs %{template_category: nil, template_content: nil, template_name: nil, uuid: nil}

    def template_fixture(attrs \\ %{}) do
      {:ok, template} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_template()

      template
    end

    test "list_templates/0 returns all templates" do
      template = template_fixture()
      assert Users.list_templates() == [template]
    end

    test "get_template!/1 returns the template with given id" do
      template = template_fixture()
      assert Users.get_template!(template.id) == template
    end

    test "create_template/1 with valid data creates a template" do
      assert {:ok, %Template{} = template} = Users.create_template(@valid_attrs)
      assert template.template_category == "some template_category"
      assert template.template_content == "some template_content"
      assert template.template_name == "some template_name"
      assert template.uuid == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_template(@invalid_attrs)
    end

    test "update_template/2 with valid data updates the template" do
      template = template_fixture()
      assert {:ok, %Template{} = template} = Users.update_template(template, @update_attrs)
      assert template.template_category == "some updated template_category"
      assert template.template_content == "some updated template_content"
      assert template.template_name == "some updated template_name"
      assert template.uuid == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_template/2 with invalid data returns error changeset" do
      template = template_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_template(template, @invalid_attrs)
      assert template == Users.get_template!(template.id)
    end

    test "delete_template/1 deletes the template" do
      template = template_fixture()
      assert {:ok, %Template{}} = Users.delete_template(template)
      assert_raise Ecto.NoResultsError, fn -> Users.get_template!(template.id) end
    end

    test "change_template/1 returns a template changeset" do
      template = template_fixture()
      assert %Ecto.Changeset{} = Users.change_template(template)
    end
  end
end
