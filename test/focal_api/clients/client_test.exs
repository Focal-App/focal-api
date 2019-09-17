defmodule FocalApi.ClientTest do
  use FocalApi.DataCase

  alias FocalApi.Clients.Client
  alias FocalApi.TestHelpers

  setup do
    user = TestHelpers.user_fixture(%{ first_name: "John" })

    client = Repo.insert!(%Client{
      client_first_name: "Snow",
      user_id: user.id,
      uuid: Ecto.UUID.generate()})

    {:ok, client: client}
  end

  test "belongs to a user", context do
    client = Client
    |> Repo.get(context[:client].id)
    |> Repo.preload(:user)

    expected_user = client.user

    assert expected_user.first_name == "John"
  end
end
