defmodule FocalApi.Accounts do
  import Ecto.Query, warn: false
  alias FocalApi.Repo
  alias FocalApi.Clients
  alias FocalApi.Accounts.User

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_uuid!(uuid), do: Repo.get_by!(User, uuid: uuid)

  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  alias FocalApi.Accounts.Contact

  def list_contacts do
    Repo.all(Contact)
  end

  def list_contacts_by_client(client_uuid) do
    client = Clients.get_client_by_uuid!(client_uuid)
    query = from contact in Contact,
              where: ^client.id == contact.client_id,
              order_by: contact.inserted_at
    Repo.all(query, preload: [:contacts])
  end

  def get_contact!(id), do: Repo.get!(Contact, id)

  def get_contact_by_uuid!(uuid), do: Repo.get_by!(Contact, uuid: uuid)

  def get_contact_by_uuid(uuid) do
    uuid
    |> gracefully_handle_get
  end

  defp gracefully_handle_get(nil), do: nil
  defp gracefully_handle_get(uuid), do: Repo.get_by(Contact, uuid: uuid)

  def create_contact(attrs \\ %{}) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert()
  end

  def update_contact(%Contact{} = contact, attrs) do
    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  def change_contact(%Contact{} = contact) do
    Contact.changeset(contact, %{})
  end
end
