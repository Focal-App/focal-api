defmodule FocalApiWeb.TemplateController do
  use FocalApiWeb, :controller

  alias FocalApi.Users
  alias FocalApi.Users.Template

  action_fallback FocalApiWeb.FallbackController

  plug FocalApiWeb.Plugs.AuthenticateSession when action in [:create]
  plug FocalApiWeb.Plugs.AuthorizeUserByUserUUID when action in []

  def index(conn, _params) do
    templates = Users.list_templates()
    render(conn, "index.json", templates: templates)
  end

  def create(conn, %{"template" => template_params}) do
    current_user = conn.assigns[:user]

    create_template_attrs = template_params
    |> Map.put_new("user_id", current_user.id)
    |> Map.put_new("uuid", Ecto.UUID.generate)

    with {:ok, %Template{} = template} <- Users.create_template(create_template_attrs) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.template_path(conn, :show, template.uuid))
      |> render("show.json", template: template)
    end
  end

  def show(conn, %{"template_uuid" => template_uuid}) do
    template = Users.get_template_by_uuid!(template_uuid)
    render(conn, "show.json", template: template)
  end

  def update(conn, %{"template_uuid" => template_uuid, "template" => template_params}) do
    template = Users.get_template_by_uuid!(template_uuid)

    with {:ok, %Template{} = template} <- Users.update_template(template, template_params) do
      render(conn, "show.json", template: template)
    end
  end

  def delete(conn, %{"template_uuid" => template_uuid}) do
    template = Users.get_template_by_uuid!(template_uuid)

    with {:ok, %Template{}} <- Users.delete_template(template) do
      send_resp(conn, :no_content, "")
    end
  end
end
