defmodule FocalApiWeb.SessionControllerTest do
  use FocalApiWeb.ConnCase
  alias FocalApi.Repo
  alias FocalApi.Accounts.User
  alias FocalApi.TestHelpers

  @client_host Application.get_env(:focal_api, :client_host)

  test "redirects user to Google for authentication", %{conn: conn} do
    conn = get conn, "/auth/google?scope=email%20profile"
    assert redirected_to(conn, 302)
  end

  test "creates user from Google information", %{conn: conn} do
    users = User |> Repo.all
    initial_user_count = Enum.count(users)

    ueberauth_auth = %{
      credentials: %{token: "fdsnoafhnoofh08h38h"},
      info: %{
        image: "image",
        email: "email@gmail.com",
        first_name: "Sam",
        provider: "google",
        token: "foo",
        },
      provider: :google
    }
    conn = conn
    |> assign(:ueberauth_auth, ueberauth_auth)
    |> get("/auth/google/callback")

    users = User |> Repo.all
    [ user | _ ] = users

    assert Enum.count(users) == initial_user_count + 1
    assert get_resp_header(conn, "location") == ["#{@client_host}/login/#{user.uuid}"]
    assert fetch_cookies(conn).cookies["session_id"] == "fdsnoafhnoofh08h38h"
  end

  test "signs out user", %{conn: conn} do
    user = TestHelpers.user_fixture()

    conn = conn
    |> assign(:user, user)
    |> get("/auth/signout")
    |> get("/auth/google")

    assert conn.assigns[:user] == nil
  end

end
