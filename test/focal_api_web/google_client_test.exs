defmodule FocalApiWeb.GoogleClientTest do
  use ExUnit.Case
  import Tesla.Mock
  alias FocalApiWeb.GoogleClient

  test "gets google user id" do
    google_id = "abcde"

    mock(fn
      %{method: :get, url: "https://www.googleapis.com/userinfo/v2/me"} ->
        %Tesla.Env{status: 200, body: %{"id" => google_id}}
    end)

    token = "sadsadsad"

    user_id =
      token
      |> GoogleClient.client()
      |> GoogleClient.get_user_id()

    assert user_id == google_id
  end

  test "sends message through google" do
    google_id = "abcde"
    encoded_email_contents = Base.encode64("
    From: Francesca Sadikin <littlegangwolf@gmail.com>
    To: Francesca Sadikin <littlegangwolf@gmail.com>
    Subject: Google API Test

    This is a message just to say hello. So, Hello.
    ")

    email_body = ~s({
      "raw": #{encoded_email_contents}
    })

    _compiled_url = "https://www.googleapis.com//gmail/v1/users/#{google_id}/messages/send"

    response_from_api = %{
      id: google_id,
      threadId: "1234",
      labelIds: [
        "UNREAD",
        "SENT",
        "INBOX"
      ]
    }

    mock(fn
      %{
        method: :post,
        url: _compiled_url,
        body: _email_body
      } ->
        %Tesla.Env{status: 200, body: response_from_api}
    end)

    token = "sadsadsad"

    response =
      token
      |> GoogleClient.client()
      |> GoogleClient.send_email(google_id, email_body)

    assert response == {:ok, response_from_api}
  end
end
