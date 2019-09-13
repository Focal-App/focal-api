defmodule FocalApi.ClientsTest do
  use FocalApi.DataCase

  alias FocalApi.Clients
  alias FocalApi.TestHelpers
  alias FocalApi.Clients.Client

  describe "clients" do
    @valid_attrs %{client_name: "some client_name", uuid: "7488a646-e31f-11e4-aace-600308960662"}
    @update_attrs %{client_name: "some updated client_name", uuid: "7488a646-e31f-11e4-aace-600308960668"}
    @invalid_attrs %{client_name: nil, uuid: nil}

    def client_fixture(attrs \\ %{}) do
      {:ok, client} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Clients.create_client()

      client
    end

    test "list_clients/0 returns all clients" do
      client = client_fixture()
      assert Clients.list_clients() == [client]
    end

    test "list_clients_by_user/1 returns all clients by user" do
      user = TestHelpers.user_fixture()
      user2 = TestHelpers.user_fixture()
      client1 = TestHelpers.client_fixture(%{ user_id: user.id })
      _client2 = TestHelpers.client_fixture(%{ user_id: user2.id })
      client3 = TestHelpers.client_fixture(%{ user_id: user.id })

      assert Clients.list_clients_by_user(user.uuid) == [client1, client3]
    end

    test "get_client!/1 returns the client with given id" do
      client = client_fixture()
      assert Clients.get_client!(client.id) == client
    end

    test "get_client_by_uuid!/1 returns the client with given uuid" do
      client = client_fixture()
      assert Clients.get_client_by_uuid!(client.uuid) == client
    end

    test "create_client/1 with valid data creates a client" do
      assert {:ok, %Client{} = client} = Clients.create_client(@valid_attrs)
      assert client.client_name == "some client_name"
      assert client.uuid == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_client/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_client(@invalid_attrs)
    end

    test "update_client/2 with valid data updates the client" do
      client = client_fixture()
      assert {:ok, %Client{} = client} = Clients.update_client(client, @update_attrs)
      assert client.client_name == "some updated client_name"
      assert client.uuid == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_client/2 with invalid data returns error changeset" do
      client = client_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.update_client(client, @invalid_attrs)
      assert client == Clients.get_client!(client.id)
    end

    test "delete_client/1 deletes the client" do
      client = client_fixture()
      assert {:ok, %Client{}} = Clients.delete_client(client)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_client!(client.id) end
    end

    test "change_client/1 returns a client changeset" do
      client = client_fixture()
      assert %Ecto.Changeset{} = Clients.change_client(client)
    end
  end

  describe "packages" do
    alias FocalApi.Clients.Package

    @valid_attrs %{package_name: "some package_name", uuid: "7488a646-e31f-11e4-aace-600308960662"}
    @update_attrs %{package_name: "some updated package_name", uuid: "7488a646-e31f-11e4-aace-600308960668"}
    @invalid_attrs %{package_name: nil, uuid: nil}

    def package_fixture(attrs \\ %{}) do
      {:ok, package} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Clients.create_package()

      package
    end

    test "list_packages/0 returns all packages" do
      package = package_fixture()
      assert Clients.list_packages() == [package]
    end

    test "list_packages_by_client/1 returns all packages for a client" do
      client1 = TestHelpers.client_fixture()
      client2 = TestHelpers.client_fixture()

      package1 = package_fixture(%{ client_id: client1.id })
      _package2 = package_fixture(%{ client_id: client2.id })
      package3 = package_fixture(%{ client_id: client1.id })

      assert Clients.list_packages_by_client(client1.uuid) == [package1, package3]
    end

    test "get_package!/1 returns the package with given id" do
      package = package_fixture()
      assert Clients.get_package!(package.id) == package
    end

    test "get_package_by_uuid!/1 returns the package with given uuid" do
      package = package_fixture()
      assert Clients.get_package_by_uuid!(package.uuid) == package
    end

    test "create_package/1 with valid data creates a package" do
      assert {:ok, %Package{} = package} = Clients.create_package(@valid_attrs)
      assert package.package_name == "some package_name"
      assert package.uuid == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_package/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_package(@invalid_attrs)
    end

    test "update_package/2 with valid data updates the package" do
      package = package_fixture()
      assert {:ok, %Package{} = package} = Clients.update_package(package, @update_attrs)
      assert package.package_name == "some updated package_name"
      assert package.uuid == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_package/2 with invalid data returns error changeset" do
      package = package_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.update_package(package, @invalid_attrs)
      assert package == Clients.get_package!(package.id)
    end

    test "delete_package/1 deletes the package" do
      package = package_fixture()
      assert {:ok, %Package{}} = Clients.delete_package(package)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_package!(package.id) end
    end

    test "change_package/1 returns a package changeset" do
      package = package_fixture()
      assert %Ecto.Changeset{} = Clients.change_package(package)
    end
  end
end
