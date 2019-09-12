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
end
