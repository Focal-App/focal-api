defmodule FocalApiWeb.ContactView do
  use FocalApiWeb, :view
  alias FocalApiWeb.ContactView

  def render("index.json", %{contacts: contacts}) do
    %{data: render_many(contacts, ContactView, "contact.json")}
  end

  def render("show.json", %{contact: contact}) do
    %{data: render_one(contact, ContactView, "contact.json")}
  end

  def render("contact.json", %{contact: contact}) do
    %{
      first_name: contact.first_name,
      last_name: contact.last_name,
      email: contact.email,
      phone_number: contact.phone_number,
      best_time_to_contact: contact.best_time_to_contact,
      uuid: contact.uuid,
      label: contact.label
    }
  end
end
