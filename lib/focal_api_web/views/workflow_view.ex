defmodule FocalApiWeb.WorkflowView do
  use FocalApiWeb, :view
  alias FocalApiWeb.WorkflowView
  alias FocalApi.Clients

  def render("index.json", %{workflows: workflows}) do
    %{data: render_many(workflows, WorkflowView, "workflow.json")}
  end

  def render("show.json", %{workflow: workflow}) do
    %{data: render_one(workflow, WorkflowView, "workflow.json")}
  end

  def render("workflow.json", %{workflow: workflow}) do
    %{
      uuid: workflow.uuid,
      workflow_name: workflow.workflow_name,
      completed_tasks: Clients.list_completed_tasks_by_workflow(workflow.uuid),
      incomplete_tasks: Clients.list_incomplete_tasks_by_workflow(workflow.uuid),
      order: workflow.order
    }
  end
end
