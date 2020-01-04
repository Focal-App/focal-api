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
  alias FocalApi.Clients.Workflow

  def user_fixture(attrs \\ %{}) do
    params =
      attrs
      |> Enum.into(%{
        avatar: "google-avatar",
        email: "user@gmail.com",
        first_name: "Test User",
        provider: "google",
        uuid: Ecto.UUID.generate(),
        google_id: "1234",
        google_refresh_token: "1234",
        google_access_token: "1234"
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
        user_id: user.id
      })

    {:ok, client} =
      Client.changeset(%Client{}, params)
      |> Repo.insert()

    client
  end

  def contact_fixture(attrs \\ %{}) do
    client = client_fixture()

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
        client_id: client.id
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
        package_price: 500_000,
        retainer_price: 100_000,
        retainer_paid_amount: 0,
        retainer_paid: false,
        discount_offered: 0,
        balance_remaining: 500_000,
        balance_received: false,
        uuid: Ecto.UUID.generate(),
        client_id: client.id,
        wedding_included: true,
        engagement_included: true
      })

    {:ok, package} =
      Package.changeset(%Package{}, params)
      |> Repo.insert()

    package
  end

  def event_fixture(attrs \\ %{}) do
    client = client_fixture()
    package = package_fixture(%{client_id: client.id})
    {:ok, date1, _} = DateTime.from_iso8601("2010-04-17T14:00:00Z")

    params =
      attrs
      |> Enum.into(%{
        event_name: "some event_name",
        shoot_date: date1,
        uuid: Ecto.UUID.generate(),
        client_id: client.id,
        package_id: package.id,
        shoot_time: "6AM - 11AM",
        shoot_location: "Los Angeles Poppy Fields",
        edit_image_deadline: date1,
        gallery_link: "http://google.com",
        blog_link: "http://google.com",
        wedding_location: nil,
        reception_location: nil,
        coordinator_name: nil,
        notes: "Have clients bring extra flowers and a see through chair."
      })

    {:ok, event} =
      Event.changeset(%Event{}, params)
      |> Repo.insert()

    event
  end

  def task_fixture(attrs \\ %{}) do
    client = client_fixture()
    event = event_fixture(%{client_id: client.id})
    workflow = workflow_fixture(%{client_id: client.id})

    params =
      attrs
      |> Enum.into(%{
        category: "some category",
        is_completed: false,
        step: "some step",
        uuid: Ecto.UUID.generate(),
        client_id: client.id,
        event_id: event.id,
        workflow_id: workflow.id,
        order: 0
      })

    {:ok, task} =
      Task.changeset(%Task{}, params)
      |> Repo.insert()

    task
  end

  def workflow_fixture(attrs \\ %{}) do
    client = client_fixture()

    params =
      attrs
      |> Enum.into(%{
        workflow_name: "New Client Inquiry",
        uuid: Ecto.UUID.generate(),
        client_id: client.id,
        order: 0
      })

    {:ok, workflow} =
      Workflow.changeset(%Workflow{}, params)
      |> Repo.insert()

    workflow
  end

  def valid_session(conn, user) do
    conn
    |> assign(:user, user)
    |> init_test_session(id: "test_id_token")
    |> put_session(:user_uuid, user.uuid)
    |> put_resp_cookie("session_id", "test_id_token", http_only: true, secure: false)
  end

  def invalid_session(conn, id_token) do
    init_test_session(conn, id: id_token)
  end

  def preloaded_package(uuid) do
    uuid
    |> Clients.get_package_by_uuid!()
    |> Repo.preload(:client)
  end

  def preloaded_client(uuid) do
    uuid
    |> Clients.get_client_by_uuid!()
    |> Repo.preload(:user)
    |> Repo.preload(:contacts)
  end

  def preloaded_event(uuid) do
    uuid
    |> Clients.get_event_by_uuid!()
    |> Repo.preload(:client)
    |> Repo.preload(:package)
  end

  def preloaded_task(uuid) do
    uuid
    |> Clients.get_task_by_uuid!()
    |> Repo.preload(:client)
    |> Repo.preload(:event)
    |> Repo.preload(:workflow)
  end

  def preloaded_workflow(uuid) do
    uuid
    |> Clients.get_workflow_by_uuid!()
    |> Repo.preload(:client)
    |> Repo.preload(:task)
  end
end
