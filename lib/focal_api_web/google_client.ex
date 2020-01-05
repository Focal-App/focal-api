defmodule FocalApiWeb.GoogleClient do
  def get_user_id(client) do
    {:ok, response} = Tesla.get(client, "/userinfo/v2/me")
    response.body["id"]
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
