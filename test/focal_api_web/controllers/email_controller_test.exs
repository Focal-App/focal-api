defmodule FocalApiWeb.EmailControllerTest do
  use FocalApiWeb.ConnCase
  alias FocalApi.TestHelpers
  import Tesla.Mock

  @create_attrs %{
    sender: "fsadikin@mail.com",
    recipients: ["jane@mail.com", "mary@mail.com"],
    subject: "Hello from focal",
    content: "<div><h1>Hiya!</h1></div>"
  }
  @invalid_attrs %{
    sender: nil,
    recipients: [nil],
    subject: nil,
    content: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "send email" do
    setup [:create_user]

    test "sends email through gmail api when data is valid", %{conn: conn, user: user} do
      _user_uuid = user.uuid
      google_id = user.google_id
      _compiled_url = "https://www.googleapis.com//gmail/v1/users/#{google_id}/messages/send"

      response_from_api = %{
        "id" => google_id,
        "threadId" => "1234",
        "labelIds" => [
          "UNREAD",
          "SENT",
          "INBOX"
        ]
      }

      mock(fn
        %{
          method: :post,
          url: _compiled_url
        } ->
          %Tesla.Env{status: 200, body: response_from_api}
      end)

      conn =
        conn
        |> TestHelpers.valid_session(user)
        |> post(Routes.email_path(conn, :create), @create_attrs)

      assert %{"email_id" => "1234"} == json_response(conn, 200)["data"]
    end

    test "renders error when data is invalid", %{conn: conn, user: user} do
      _user_uuid = user.uuid

      conn =
        conn
        |> TestHelpers.valid_session(user)
        |> post(Routes.email_path(conn, :create), @invalid_attrs)

      assert json_response(conn, 422)["errors"] == %{
               "content" => ["can't be blank"],
               "subject" => ["can't be blank"]
             }
    end

    test "renders error when user is not logged in", %{conn: conn, user: _user} do
      conn = post(conn, Routes.email_path(conn, :create), @create_attrs)

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    test "renders error when user is logged in but request is not authenticated", %{
      conn: conn,
      user: _user
    } do
      conn =
        conn
        |> TestHelpers.invalid_session("test_id_token")
        |> post(Routes.email_path(conn, :create), @create_attrs)

      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end

    # TODO renders error when user is logged in but sender does not match session user
  end

  defp create_user(_) do
    user = TestHelpers.user_fixture()
    {:ok, user: user}
  end
end
