defmodule FocalApiWeb.TaskView do
  use FocalApiWeb, :view

  alias FocalApiWeb.TaskView
  alias FocalApi.Clients

  def render("index.json", %{tasks: tasks}) do
    %{data: render_many(tasks, TaskView, "task.json")}
  end

  def render("show.json", %{task: task}) do
    %{data: render_one(task, TaskView, "task.json")}
  end

  def render("task.json", %{task: task}) do
    %{
      uuid: task.uuid,
      category: task.category,
      step: task.step,
      is_completed: task.is_completed,
      client_uuid: client_uuid(task),
      event_uuid: event_uuid(task)
    }
  end

  defp client_uuid(task) do
    client = Clients.get_client!(task.client_id)
    client.uuid
  end

  defp event_uuid(task) do
    event = Clients.get_event(task.event_id)
    if (is_nil(event)), do: nil, else: event.uuid
  end
end
