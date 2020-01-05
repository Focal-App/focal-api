defmodule FocalApiWeb.EmailController do
  use FocalApiWeb, :controller

  alias FocalApi.IncomingEmail
  alias FocalApiWeb.EmailCreator
  alias FocalApiWeb.GoogleClient
  alias FocalApi.Accounts.User

  action_fallback FocalApiWeb.FallbackController

  plug FocalApiWeb.Plugs.AuthenticateSession when action in [:create]

  def create(conn, params) do
    with {:ok, %IncomingEmail{} = email} <- validate_email(params) do
      with {:ok, email_result} <- send_email(conn, email) do
        conn
        |> put_status(:ok)
        |> render("show.json", email_result: email_result)
      end
    end
  end

  defp send_email(conn, email) do
    current_user = conn.assigns[:user]
    %User{google_access_token: token, google_id: google_id} = current_user
    generated_email = EmailCreator.gmail_generator(email)

    token
    |> GoogleClient.client()
    |> GoogleClient.send_email(google_id, generated_email)
  end

  defp validate_email(attrs) do
    result =
      %IncomingEmail{}
      |> IncomingEmail.changeset(attrs)

    case result.valid? do
      true -> {:ok, Map.merge(%IncomingEmail{}, result.changes)}
      false -> {:error, result}
    end
  end
end
