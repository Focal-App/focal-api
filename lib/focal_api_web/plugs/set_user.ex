defmodule FocalApi.Plugs.SetUser do
  import Plug.Conn

  alias FocalApi.Repo
  alias FocalApi.Accounts.User

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      session_uuid = get_session(conn, :user_uuid)

      cond do
        user = session_uuid && Repo.get_by(User, uuid: session_uuid) ->
          assign(conn, :user, user)

        true ->
          assign(conn, :user, nil)
      end
    end
  end
end
