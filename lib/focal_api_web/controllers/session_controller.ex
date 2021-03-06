defmodule FocalApiWeb.SessionController do
  use FocalApiWeb, :controller
  plug Ueberauth

  alias FocalApi.Repo
  alias FocalApi.Accounts.User

  @client_host Application.get_env(:focal_api, :client_host)

  def create(%{assigns: %{ueberauth_auth: auth}} = conn, %{"provider" => provider}) do
    user_params = user_params(auth, provider)
    changeset = User.changeset(%User{}, user_params)

    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_session(:id, auth.credentials.token)
        |> put_session(:user_uuid, user.uuid)
        |> put_resp_cookie("session_id", auth.credentials.token, [http_only: true])
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

  defp user_params(auth, provider) do
    %{
      avatar: auth.info.image,
      email: auth.info.email,
      first_name: auth.info.first_name,
      provider: provider,
      uuid: Ecto.UUID.generate()
    }
  end

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        Repo.insert(changeset)
      user ->
        {:ok, user}
    end
  end
end
