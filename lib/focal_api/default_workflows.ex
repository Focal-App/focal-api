defmodule FocalApi.DefaultWorkflows do
  alias FocalApi.Clients
  alias FocalApi.DefaultTasks
  alias FocalApi.EventName

  def create_new_client_workflow_and_tasks(client) do
    new_client_workflow(client)
    proposal_and_retainer_workflow(client)
  end

  def new_client_workflow(client, order \\ 0) do
    name = "New Client Inquiry"
    {:ok, new_client_workflow} = Clients.create_workflow(%{
      uuid: Ecto.UUID.generate(),
      client_id: client.id,
      order: order,
      workflow_name: name,
    })

    DefaultTasks.new_client_inquiry_tasks()
    |> create_workflow_task(client.id, new_client_workflow.id, name)
  end

  def proposal_and_retainer_workflow(client, order \\ 1) do
    name = "Proposal & Retainer"
    {:ok, proposal_workflow} = Clients.create_workflow(%{
      uuid: Ecto.UUID.generate(),
      client_id: client.id,
      order: order,
      workflow_name: name,
    })

    DefaultTasks.proposal_and_retainer_tasks()
    |> create_workflow_task(client.id, proposal_workflow.id, name)
  end

  def create_engagement_workflow_and_tasks(client, order) do
    name = EventName.engagement()
    {:ok, engagement_workflow} = Clients.create_workflow(%{
      uuid: Ecto.UUID.generate(),
      client_id: client.id,
      order: order,
      workflow_name: name,
    })

    DefaultTasks.engagement_tasks()
    |> create_workflow_task(client.id, engagement_workflow.id, name)
  end

  def create_wedding_workflow_and_tasks(client, order) do
    name = EventName.wedding()
    {:ok, wedding_workflow} = Clients.create_workflow(%{
      uuid: Ecto.UUID.generate(),
      client_id: client.id,
      order: order,
      workflow_name: name,
    })

    DefaultTasks.wedding_tasks()
    |> create_workflow_task(client.id, wedding_workflow.id, name)
  end

  def create_closeout_workflow_and_tasks(client, order) do
    name = "Closeout"
    {:ok, closeout_workflow} = Clients.create_workflow(%{
      uuid: Ecto.UUID.generate(),
      client_id: client.id,
      order: order,
      workflow_name: name,
    })

    DefaultTasks.closeout_tasks()
    |> create_workflow_task(client.id, closeout_workflow.id, name)
  end

  defp create_workflow_task(tasks_list, client_id, workflow_id, category_name) do
    tasks_list
    |> Enum.map(fn task ->
      Clients.create_task(%{
        uuid: Ecto.UUID.generate(),
        client_id: client_id,
        workflow_id: workflow_id,
        category: category_name,
        step: task.step,
        is_completed: false,
        order: task.order
      })
    end)
    |> handle_results()
  end

  defp handle_results(list) do
    list
    |> Enum.reduce(fn result, acc ->
      case result do
        {:error, _changeset} -> result
        {:ok, _contact} -> acc
      end
    end)
  end

end
