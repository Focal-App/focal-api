defmodule FocalApi.PackageTest do
  use FocalApi.DataCase

  alias FocalApi.Clients.Package
  alias FocalApi.TestHelpers

  @client_uuid Ecto.UUID.generate()

  setup do
    client = TestHelpers.client_fixture(%{ uuid: @client_uuid })

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

    assert expected_client.uuid == @client_uuid
  end
end
