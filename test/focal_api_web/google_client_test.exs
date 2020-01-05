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
end
