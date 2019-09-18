# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FocalApi.Repo.insert!(%FocalApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias FocalApi.Clients
alias FocalApi.Clients.Client
alias FocalApi.Clients.Package
alias FocalApi.Clients.Event
alias FocalApi.Clients.Task
alias FocalApi.Accounts.User
alias FocalApi.Accounts
alias FocalApi.Repo

{:ok, date, _} = DateTime.from_iso8601("2020-04-17T14:00:00Z")
date = date |> DateTime.truncate(:second)

francesca = Accounts.get_user_by_email("littlegangwolf@gmail.com")

# Francesca Client 1
francesca_client = %Client{
  private_notes: nil,
  uuid: Ecto.UUID.generate(),
  user_id: francesca.id
}
Repo.insert!(francesca_client)
francesca_client = Repo.get_by(Client, uuid: francesca_client.uuid)

francesca_client_package = %Package{
  package_name: "Wedding Premier",
  uuid: Ecto.UUID.generate(),
  client_id: francesca_client.id
}
Repo.insert!(francesca_client_package)
francesca_client_package = Repo.get_by(Package, uuid: francesca_client_package.uuid)

francesca_client_event = %Event{
  event_name: "Engagement",
  shoot_date: date,
  uuid: Ecto.UUID.generate(),
  client_id: francesca_client.id,
  package_id: francesca_client_package.id
}
Repo.insert!(francesca_client_event)
francesca_client_event = Repo.get_by(Event, uuid: francesca_client_event.uuid)

francesca_client_task = %Task{
  category: "New Client Inquiry",
  is_completed: false,
  step: "Request More Information",
  uuid: Ecto.UUID.generate(),
  client_id: francesca_client.id,
  event_id: francesca_client_event.id
}
Repo.insert!(francesca_client_task)
francesca_client_task = Repo.get_by(Task, uuid: francesca_client_task.uuid)

# Francesca Client 2
francesca_client2 = %Client{
  private_notes: nil,
  uuid: Ecto.UUID.generate(),
  user_id: francesca.id
}
Repo.insert!(francesca_client2)
francesca_client2 = Repo.get_by(Client, uuid: francesca_client2.uuid)

francesca_client_package2 = %Package{
  package_name: "Wedding Classic",
  uuid: Ecto.UUID.generate(),
  client_id: francesca_client2.id
}
Repo.insert!(francesca_client_package2)
francesca_client_package2 = Repo.get_by(Package, uuid: francesca_client_package2.uuid)

francesca_client_event2 = %Event{
  event_name: "Engagement",
  shoot_date: date,
  uuid: Ecto.UUID.generate(),
  client_id: francesca_client2.id,
  package_id: francesca_client_package2.id
}
Repo.insert!(francesca_client_event2)
francesca_client_event2 = Repo.get_by(Event, uuid: francesca_client_event2.uuid)

francesca_client_task2 = %Task{
  category: "Proposal & Retainer",
  is_completed: false,
  step: "Confirm Proposal & Retainer",
  uuid: Ecto.UUID.generate(),
  client_id: francesca_client2.id,
  event_id: francesca_client_event2.id
}
Repo.insert!(francesca_client_task2)
francesca_client_task2 = Repo.get_by(Task, uuid: francesca_client_task2.uuid)
