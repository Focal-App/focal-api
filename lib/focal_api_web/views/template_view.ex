defmodule FocalApiWeb.TemplateView do
  use FocalApiWeb, :view
  alias FocalApiWeb.TemplateView
  alias FocalApi.Users.Template
  alias FocalApi.Repo

  def render("index.json", %{templates: templates}) do
    %{data: render_many(templates, TemplateView, "template.json")}
  end

  def render("show.json", %{template: template}) do
    %{data: render_one(template, TemplateView, "template.json")}
  end

  def render("template.json", %{template: template}) do
    %{
      uuid: template.uuid,
      template_name: template.template_name,
      template_category: template.template_category,
      template_content: template.template_content,
      updated_at: template.updated_at,
      user_uuid: user_uuid(template.uuid)
    }
  end

  defp user_uuid(uuid) do
    template = preloaded_template(uuid)
    template.user.uuid
  end

  def preloaded_template(uuid) do
    Template
    |> Repo.get_by!(uuid: uuid)
    |> Repo.preload(:user)
  end
end
