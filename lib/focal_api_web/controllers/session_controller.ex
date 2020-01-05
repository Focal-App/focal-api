defmodule FocalApiWeb.SessionController do
  use FocalApiWeb, :controller

  alias FocalApi.Repo
  alias FocalApi.Accounts.User
  alias FocalApiWeb.GoogleClient

  plug Ueberauth

  @client_host Application.get_env(:focal_api, :client_host)

  def create(%{assigns: %{ueberauth_auth: auth}} = conn, %{"provider" => provider}) do
    user_google_id =
      auth.credentials.token
      |> GoogleClient.client()
      |> GoogleClient.get_user_id()

    user_params = user_params(auth, provider, user_google_id)

    case insert_or_update_user(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:id, auth.credentials.token)
        |> put_session(:user_uuid, user.uuid)
        |> put_resp_cookie("session_id", auth.credentials.token, http_only: true)
        |> redirect(external: "#{@client_host}/login/#{user.uuid}")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(FocalApiWeb.ChangesetView)
        |> render("error.json", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_view(FocalApiWeb.DefaultView)
    |> render("show.json", value: "Ok")
  end

  defp user_params(auth, provider, user_google_id) do
    %{
      avatar: auth.info.image,
      email: auth.info.email,
      first_name: auth.info.first_name,
      provider: provider,
      uuid: Ecto.UUID.generate(),
      google_access_token: auth.credentials.token,
      google_refresh_token: auth.credentials.refresh_token,
      google_id: user_google_id
    }
  end

  defp insert_or_update_user(user_params) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        Repo.insert(changeset)

      user ->
        User.changeset(user, user_params) |> Repo.update()
    end
  end
end

# TODO
# Store access token + refresh token
# Get offline access
# Exchange refresh token for new access token to be stored in user session
# If refresh token is revoked or invalid, get new refresh token
# If an error occurs, the code checks for an HTTP 401 status code, which should be handled by redirecting the user to the authorization URL.
