defmodule FocalApi.TestHelpers do
  use Plug.Test

  alias FocalApi.Repo
  alias FocalApi.Accounts.User

  def user_fixture(attrs \\ %{}) do
    params =
      attrs
      |> Enum.into(%{
        avatar: "google-avatar",
        email: "user@gmail.com",
        first_name: "Tommy",
        provider: "google",
        uuid: Ecto.UUID.generate(),
      })

    {:ok, user} =
      User.changeset(%User{}, params)
      |> Repo.insert()

    user
  end
end
