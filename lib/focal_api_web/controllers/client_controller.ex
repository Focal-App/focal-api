defmodule FocalApiWeb.ClientController do
  use FocalApiWeb, :controller

  alias FocalApi.Clients
  alias FocalApi.Clients.Client
  alias FocalApi.Accounts
  alias FocalApi.Repo
  alias FocalApi.DefaultWorkflows

  action_fallback FocalApiWeb.FallbackController

  plug FocalApiWeb.Plugs.AuthenticateSession
       when action in [:create, :update, :delete, :index_by_user, :show, :show_all_client_data]

  plug FocalApiWeb.Plugs.AuthorizeUserByClientUUID
       when action in [:update, :delete, :show, :show_all_client_data]

  plug FocalApiWeb.Plugs.AuthorizeUserByUserUUID when action in [:index_by_user]

  def index_by_user(conn, %{"user_uuid" => user_uuid}) do
    clients = Clients.list_clients_by_user(user_uuid)
    render(conn, "index.json", clients: clients)
  end

  def index_of_all_client_data_by_user(conn, %{"user_uuid" => user_uuid}) do
    clients = Clients.list_clients_by_user(user_uuid)
    render(conn, "index_of_partial_client_data.json", clients: clients)
  end

  def create(conn, params) do
    current_user = conn.assigns[:user]

    create_client_attrs =
      params
      |> Map.put("user_id", current_user.id)
      |> Map.put_new("uuid", Ecto.UUID.generate())

    {:ok, %Client{} = client} = Clients.create_client(create_client_attrs)

    with {:ok, _contact} <- handle_contact_update_or_create(params["contacts"], client) do
      with {:ok, _workflow} <- DefaultWorkflows.create_new_client_workflow_and_tasks(client) do
        client = Clients.get_client_by_uuid!(client.uuid)

        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.client_path(conn, :show, client))
        |> render("show.json", client: client)
      end
    end
  end

  def show(conn, %{"client_uuid" => client_uuid}) do
    client = Clients.get_client_by_uuid!(client_uuid)
    render(conn, "show.json", client: client)
  end

  def show_all_client_data(conn, %{"client_uuid" => client_uuid}) do
    client = Clients.get_client_by_uuid!(client_uuid)
    render(conn, "show_all_client_data.json", client: client)
  end

  def update(conn, params) do
    client_uuid = params["client_uuid"]
    client = Clients.get_client_by_uuid!(client_uuid) |> Repo.preload(:contacts)

    with {:ok, _contact} <- handle_contact_update_or_create(params["contacts"], client) do
      update_client_attrs =
        params
        |> Map.put("uuid", client_uuid)

      with {:ok, %Client{} = client} <- Clients.update_client(client, update_client_attrs) do
        render(conn, "show_all_client_data.json", client: client)
      end
    end
  end

  def delete(conn, %{"client_uuid" => client_uuid}) do
    client = Clients.get_client_by_uuid!(client_uuid)

    with {:ok, %Client{}} <- Clients.delete_client(client) do
      conn
      |> put_view(FocalApiWeb.DefaultView)
      |> render("show.json", value: "Ok")
    end
  end

  defp handle_contact_update_or_create(contacts, client) do
    contacts
    |> Enum.map(fn contact ->
      if Map.has_key?(contact, "uuid"),
        do: update_contact(contact),
        else: create_contact(contact, client)
    end)
    |> Enum.reduce(fn result, acc ->
      case result do
        {:error, _changeset} -> result
        {:ok, _contact} -> acc
      end
    end)
  end

  defp create_contact(contact, client) do
    contact
    |> Map.put("uuid", Ecto.UUID.generate())
    |> Map.put("client_id", client.id)
    |> Accounts.create_contact()
  end

  defp update_contact(contact) do
    original_contact = Accounts.get_contact_by_uuid(contact["uuid"])
    contact = Map.put(contact, "uuid", original_contact.uuid)
    Accounts.update_contact(original_contact, contact)
  end
end
