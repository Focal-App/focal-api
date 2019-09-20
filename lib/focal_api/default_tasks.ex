defmodule FocalApi.DefaultTasks do
  alias FocalApi.Clients

  def create_new_client_workflow_and_tasks(client) do
    {:ok, new_client_workflow} = Clients.create_workflow(%{
      uuid: Ecto.UUID.generate(),
      client_id: client.id,
      order: 0,
      workflow_name: "New Client Inquiry",
    })

    Clients.create_task(%{
      uuid: Ecto.UUID.generate(),
      client_id: client.id,
      workflow_id: new_client_workflow.id,
      category: "New Client Inquiry",
      step: "Request More Information",
      is_completed: false
    })

    Clients.create_task(%{
      uuid: Ecto.UUID.generate(),
      client_id: client.id,
      workflow_id: new_client_workflow.id,
      category: "New Client Inquiry",
      step: "Save Client Information",
      is_completed: false
    })

    {:ok, proposal_workflow} = Clients.create_workflow(%{
      uuid: Ecto.UUID.generate(),
      client_id: client.id,
      order: 1,
      workflow_name: "Proposal & Retainer",
    })

    Clients.create_task(%{
      uuid: Ecto.UUID.generate(),
      client_id: client.id,
      workflow_id: proposal_workflow.id,
      category: "Proposal & Retainer",
      step: "Send Proposal",
      is_completed: false
    })

    Clients.create_task(%{
      uuid: Ecto.UUID.generate(),
      client_id: client.id,
      workflow_id: proposal_workflow.id,
      category: "Proposal & Retainer",
      step: "Commit To Proposal",
      is_completed: false
    })

    Clients.create_task(%{
      uuid: Ecto.UUID.generate(),
      client_id: client.id,
      workflow_id: proposal_workflow.id,
      category: "Proposal & Retainer",
      step: "Receive Signed Proposal & Retainer",
      is_completed: false
    })

    Clients.create_task(%{
      uuid: Ecto.UUID.generate(),
      client_id: client.id,
      workflow_id: proposal_workflow.id,
      category: "Proposal & Retainer",
      step: "Receive Retainer Fee",
      is_completed: false
    })
  end
end
