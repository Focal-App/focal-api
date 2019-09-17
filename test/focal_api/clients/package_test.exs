defmodule FocalApi.PackageTest do
  use FocalApi.DataCase

  alias FocalApi.Clients.Package
  alias FocalApi.TestHelpers

  setup do
    client = TestHelpers.client_fixture(%{ client_first_name: "John" })

    package = Repo.insert!(%Package{
      package_name: "Engagements",
      client_id: client.id,
      uuid: Ecto.UUID.generate()})

    {:ok, package: package}
  end

  test "package belongs to a client", context do
    package = Package
    |> Repo.get(context[:package].id)
    |> Repo.preload(:client)

    expected_client = package.client

    assert expected_client.client_first_name == "John"
  end
end
