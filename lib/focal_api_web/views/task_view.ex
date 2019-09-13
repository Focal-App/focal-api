defmodule FocalApiWeb.TaskView do
  use FocalApiWeb, :view
  alias FocalApiWeb.TaskView
  alias FocalApi.TestHelpers

  def render("index.json", %{tasks: tasks}) do
    %{data: render_many(tasks, TaskView, "task.json")}
  end

  def render("show.json", %{task: task}) do
    %{data: render_one(task, TaskView, "task.json")}
  end

  def render("task.json", %{task: task}) do
    task = TestHelpers.preloaded_task(task.uuid)
    event_uuid = if (is_nil(task.event)), do: nil, else: task.event.uuid
    %{
      uuid: task.uuid,
      category: task.category,
      step: task.step,
      is_completed: task.is_completed,
      client_uuid: task.client.uuid,
      event_uuid: event_uuid
    }
  end
end
