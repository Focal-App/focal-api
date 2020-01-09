defmodule FocalApiWeb.TemplateView do
  use FocalApiWeb, :view
  alias FocalApiWeb.TemplateView

  def render("index.json", %{templates: templates}) do
    %{data: render_many(templates, TemplateView, "template.json")}
  end

  def render("show.json", %{template: template}) do
    %{data: render_one(template, TemplateView, "template.json")}
  end

  def render("template.json", %{template: template}) do
    %{id: template.id,
      uuid: template.uuid,
      template_name: template.template_name,
      template_category: template.template_category,
      template_content: template.template_content}
  end
end
