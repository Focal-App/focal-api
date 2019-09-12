defmodule FocalApi.TestHelpers do
  use Plug.Test

  alias FocalApi.Repo
  alias FocalApi.Accounts.User
  alias FocalApi.Clients.Client
  alias FocalApi.Clients.Package

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
        client_name: "Snow",
        uuid: Ecto.UUID.generate(),
        user_id: user.id,
      })

    {:ok, client} =
      Client.changeset(%Client{}, params)
      |> Repo.insert()

    client
  end

  def package_fixture(attrs \\ %{}) do
    client = client_fixture()

    params =
      attrs
      |> Enum.into(%{
        package_name: "some package_name",
        uuid: "7488a646-e31f-11e4-aace-600308960662",
        client_id: client.id,
      })

    {:ok, package} =
      Package.changeset(%Package{}, params)
      |> Repo.insert()

      package
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
end
