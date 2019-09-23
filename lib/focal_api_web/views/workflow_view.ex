defmodule FocalApiWeb.WorkflowView do
  use FocalApiWeb, :view
  alias FocalApiWeb.WorkflowView
  alias FocalApiWeb.TaskView
  alias FocalApi.Clients
  alias FocalApi.Repo

  def render("index.json", %{workflows: workflows}) do
    %{data: render_many(workflows, WorkflowView, "workflow.json")}
  end

  def render("show.json", %{workflow: workflow}) do
    %{data: render_one(workflow, WorkflowView, "workflow.json")}
  end

  def render("workflow.json", %{workflow: workflow}) do
    workflow = preloaded_workflow(workflow.uuid)
    completed_tasks = Clients.list_completed_tasks_by_workflow(workflow.uuid)
    incomplete_tasks = Clients.list_incomplete_tasks_by_workflow(workflow.uuid)
    %{
      uuid: workflow.uuid,
      workflow_name: workflow.workflow_name,
      tasks: render_many(workflow.task, TaskView, "task.json"),
      completed_tasks: length(completed_tasks),
      incomplete_tasks: length(incomplete_tasks),
      order: workflow.order
    }
  end

  defp preloaded_workflow(uuid) do
    uuid
    |> Clients.get_workflow_by_uuid!()
    |> Repo.preload(:task)
  end
end
