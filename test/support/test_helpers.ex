defmodule FocalApi.TestHelpers do
  use Plug.Test

  alias FocalApi.Repo
  alias FocalApi.Accounts.User
  alias FocalApi.Accounts.Contact
  alias FocalApi.Clients.Client
  alias FocalApi.Clients
  alias FocalApi.Clients.Package
  alias FocalApi.Clients.Event
  alias FocalApi.Clients.Task

  def user_fixture(attrs \\ %{}) do
    params =
      attrs
      |> Enum.into(%{
        avatar: "google-avatar",
        email: "user@gmail.com",
        first_name: "Test User",
        provider: "google",
        uuid: Ecto.UUID.generate(),
      })

    {:ok, user} =
      User.changeset(%User{}, params)
      |> Repo.insert()

    user
  end

  def client_fixture(attrs \\ %{}) do
    user = user_fixture()

    params =
      attrs
      |> Enum.into(%{
        private_notes: nil,
        uuid: Ecto.UUID.generate(),
        user_id: user.id,
      })

    {:ok, client} =
      Client.changeset(%Client{}, params)
      |> Repo.insert()

    _contact = contact_fixture(%{ client_id: client.id })
    client
  end

  def contact_fixture(attrs \\ %{}) do
    params =
      attrs
      |> Enum.into(%{
        best_time_to_contact: "some best_time_to_contact",
        email: "some@email.com",
        first_name: "some first_name",
        label: "some label",
        last_name: "some last_name",
        phone_number: "some phone_number",
        uuid: Ecto.UUID.generate(),
      })

    {:ok, contact} =
      Contact.changeset(%Contact{}, params)
      |> Repo.insert()

      contact
  end

  def package_fixture(attrs \\ %{}) do
    client = client_fixture()

    params =
      attrs
      |> Enum.into(%{
        package_name: "some package_name",
        proposal_signed: false,
        package_contents: ~s(Up To Ten Hours of Photographic Coverage

        Two Photographers

        Handcrafted 10x10 Thirty Sided
        Artisan Album

        Complimentary Engagement Session

        Private Online Gallery of All Images for Friends and Family

        Seven Hundred+ Digital Negatives on a Custom USB Drive),
        package_price: 500000,
        retainer_price: 100000,
        retainer_paid_amount: 0,
        retainer_paid: false,
        discount_offered: 0,
        balance_remaining: 500000,
        balance_received: false,
        uuid: Ecto.UUID.generate(),
        client_id: client.id,
        wedding_included: true,
        engagement_included: true,
      })

    {:ok, package} =
      Package.changeset(%Package{}, params)
      |> Repo.insert()

      package
  end

  def event_fixture(attrs \\ %{}) do
    client = client_fixture()
    package = package_fixture(%{ client_id: client.id })

    params =
      attrs
      |> Enum.into(%{
        event_name: "some event_name",
        shoot_date: "2010-04-17T14:00:00Z",
        uuid: Ecto.UUID.generate(),
        client_id: client.id,
        package_id: package.id
      })

    {:ok, event} =
      Event.changeset(%Event{}, params)
      |> Repo.insert()

      event
  end

  def task_fixture(attrs \\ %{}) do
    client = client_fixture()
    event = event_fixture(%{ client_id: client.id })

    params =
      attrs
      |> Enum.into(%{
        category: "some category",
        is_completed: false,
        step: "some step",
        uuid: Ecto.UUID.generate(),
        client_id: client.id,
        event_id: event.id
      })

    {:ok, task} =
      Task.changeset(%Task{}, params)
      |> Repo.insert()

      task
  end

  def valid_session(conn, user) do
    conn
    |> assign(:user, user)
    |> init_test_session(id: "test_id_token")
    |> put_session(:user_uuid, user.uuid)
    |> put_resp_cookie("session_id", "test_id_token", [http_only: true, secure: false])
  end

  def invalid_session(conn, id_token) do
    init_test_session(conn, id: id_token)
  end

  def preloaded_package(uuid) do
    uuid
    |> Clients.get_package_by_uuid!
    |> Repo.preload(:client)
  end

  def preloaded_client(uuid) do
    uuid
    |> Clients.get_client_by_uuid!
    |> Repo.preload(:user)
    |> Repo.preload(:contacts)
  end

  def preloaded_event(uuid) do
    uuid
    |> Clients.get_event_by_uuid!
    |> Repo.preload(:client)
    |> Repo.preload(:package)
  end

  def preloaded_task(uuid) do
    uuid
    |> Clients.get_task_by_uuid!
    |> Repo.preload(:client)
    |> Repo.preload(:event)
  end
end
