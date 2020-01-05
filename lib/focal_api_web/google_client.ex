defmodule FocalApiWeb.GoogleClient do
  def get_user_id(client) do
    {:ok, response} = Tesla.get(client, "/userinfo/v2/me")
    response.body["id"]
  end

  def send_email(client, user_google_id, email_content) do
    {:ok, response} =
      Tesla.post(client, "/gmail/v1/users/#{user_google_id}/messages/send", email_content)

    case response.status do
      200 -> {:ok, response.body}
      _ -> {:error, :api_errors, response.body["error"]}
    end
  end

  def client(token) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://www.googleapis.com"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"authorization", "Bearer " <> token}]}
    ]

    Tesla.client(middleware)
  end
end
