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
alias FocalApi.Accounts.Contact
alias FocalApi.Accounts
alias FocalApi.Repo

{:ok, date, _} = DateTime.from_iso8601("2020-04-17T14:00:00Z")
date = date |> DateTime.truncate(:second)

{:ok, date2, _} = DateTime.from_iso8601("2020-08-17T14:00:00Z")
date2 = date2 |> DateTime.truncate(:second)

francesca = Accounts.get_user_by_email("littlegangwolf@gmail.com")

# Francesca Client 1
francesca_client = %Client{
  private_notes: nil,
  uuid: Ecto.UUID.generate(),
  user_id: francesca.id
}
Repo.insert!(francesca_client)
francesca_client = Repo.get_by(Client, uuid: francesca_client.uuid)

francesca_client_contact = %Contact{
  best_time_to_contact: "Evening",
  email: "some@email.com",
  first_name: "Natasha",
  label: "Bride",
  last_name: "Lee",
  phone_number: "123-456-7890",
  uuid: Ecto.UUID.generate(),
  client_id: francesca_client.id
}
Repo.insert!(francesca_client_contact)
francesca_client_contact = Repo.get_by(Contact, uuid: francesca_client_contact.uuid)

francesca_client_package = %Package{
  package_name: "Wedding Premier",
  uuid: Ecto.UUID.generate(),
  client_id: francesca_client.id,
  proposal_signed: false,
  package_contents: ~s(Up To Ten Hours of Photographic Coverage

  Two Photographers

  Handcrafted 10x10 Thirty Sided
  Artisan Album

  Complimentary Engagement Session

  Private Online Gallery of All Images for Friends and Family

  Seven Hundred+ Digital Negatives on a Custom USB Drive),
  package_price: 520000,
  retainer_price: 100000,
  retainer_paid_amount: 0,
  retainer_paid: false,
  discount_offered: 0,
  balance_remaining: 520000,
  balance_received: false,
  wedding_included: true,
  engagement_included: true,
}
Repo.insert!(francesca_client_package)
francesca_client_package = Repo.get_by(Package, uuid: francesca_client_package.uuid)

francesca_client_event = %Event{
  event_name: "Engagement",
  shoot_date: date,
  uuid: Ecto.UUID.generate(),
  client_id: francesca_client.id,
  package_id: francesca_client_package.id,
  shoot_time: "6AM - 11AM",
  shoot_location: "Los Angeles Poppy Fields",
  edit_image_deadline: date,
  gallery_link: "http://google.com",
  blog_link: "http://google.com",
  wedding_location: nil,
  reception_location: nil,
  coordinator_name: nil,
  notes: "Have clients bring extra flowers and a see through chair.",
}
Repo.insert!(francesca_client_event)
francesca_client_event = Repo.get_by(Event, uuid: francesca_client_event.uuid)

francesca_client_event_3 = %Event{
  event_name: "Wedding",
  shoot_date: date2,
  uuid: Ecto.UUID.generate(),
  client_id: francesca_client.id,
  package_id: francesca_client_package.id,
  shoot_time: "8AM - 11PM",
  shoot_location: nil,
  edit_image_deadline: date2,
  gallery_link: "http://google.com",
  blog_link: "http://google.com",
  wedding_location: "Viviana Church in DTLA",
  reception_location: "Redbird DTLA",
  coordinator_name: nil,
  notes: nil,
}
Repo.insert!(francesca_client_event_3)
francesca_client_event_3 = Repo.get_by(Event, uuid: francesca_client_event_3.uuid)


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

francesca_client_contact2 = %Contact{
  best_time_to_contact: "Morning",
  email: "some@email.com",
  first_name: "Sandy",
  label: "Bride",
  last_name: "Brooks",
  phone_number: "123-456-7890",
  uuid: Ecto.UUID.generate(),
  client_id: francesca_client2.id
}
Repo.insert!(francesca_client_contact2)
francesca_client_contact2 = Repo.get_by(Contact, uuid: francesca_client_contact2.uuid)

francesca_client_package2 = %Package{
  package_name: "Wedding Classic",
  uuid: Ecto.UUID.generate(),
  client_id: francesca_client2.id,
  proposal_signed: false,
  package_contents: ~s(Up To Eight Hours of Photographic Coverage

  Handcrafted 10x10 Thirty Sided Artisan Album

  Complimentary Engagement Session

  Private Online Gallery of All Images for Friends and Family

  Five Hundred+ Digital Negatives on a Custom USB Drive),
  package_price: 480000,
  retainer_price: 100000,
  retainer_paid_amount: 100000,
  retainer_paid: true,
  discount_offered: 0,
  balance_remaining: 380000,
  balance_received: false,
  wedding_included: true,
  engagement_included: true,
}
Repo.insert!(francesca_client_package2)
francesca_client_package2 = Repo.get_by(Package, uuid: francesca_client_package2.uuid)

francesca_client_event2 = %Event{
  event_name: "Engagement",
  shoot_date: date,
  uuid: Ecto.UUID.generate(),
  client_id: francesca_client2.id,
  package_id: francesca_client_package2.id,
  shoot_time: "6AM - 12PM",
  shoot_location: "Los Angeles Poppy Fields",
  edit_image_deadline: date,
  gallery_link: "http://google.com",
  blog_link: "http://google.com",
  wedding_location: nil,
  reception_location: nil,
  coordinator_name: nil,
  notes: "Have clients bring extra flowers and a see through chair.",
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
