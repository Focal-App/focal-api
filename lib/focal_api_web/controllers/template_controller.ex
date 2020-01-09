defmodule FocalApiWeb.TemplateController do
  use FocalApiWeb, :controller

  alias FocalApi.Users
  alias FocalApi.Users.Template

  action_fallback FocalApiWeb.FallbackController

  def index(conn, _params) do
    templates = Users.list_templates()
    render(conn, "index.json", templates: templates)
  end

  def create(conn, %{"template" => template_params}) do
    with {:ok, %Template{} = template} <- Users.create_template(template_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.template_path(conn, :show, template))
      |> render("show.json", template: template)
    end
  end

  def show(conn, %{"id" => id}) do
    template = Users.get_template!(id)
    render(conn, "show.json", template: template)
  end

  def update(conn, %{"id" => id, "template" => template_params}) do
    template = Users.get_template!(id)

    with {:ok, %Template{} = template} <- Users.update_template(template, template_params) do
      render(conn, "show.json", template: template)
    end
  end

  def delete(conn, %{"id" => id}) do
    template = Users.get_template!(id)

    with {:ok, %Template{}} <- Users.delete_template(template) do
      send_resp(conn, :no_content, "")
    end
  end
end
