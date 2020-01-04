defmodule FocalApi.AccountsTest do
  use FocalApi.DataCase

  alias FocalApi.Accounts
  alias FocalApi.TestHelpers

  describe "users" do
    alias FocalApi.Accounts.User

    @valid_attrs %{
      avatar: "some avatar",
      email: "some email",
      first_name: "some first_name",
      provider: "some provider",
      uuid: "7488a646-e31f-11e4-aace-600308960662",
      google_id: "1234",
      google_refresh_token: "1234"
    }
    @update_attrs %{
      avatar: "some updated avatar",
      email: "some updated email",
      first_name: "some updated first_name",
      provider: "some updated provider",
      uuid: "7488a646-e31f-11e4-aace-600308960668",
      google_id: "1234",
      google_refresh_token: "1234"
    }
    @invalid_attrs %{
      avatar: nil,
      email: nil,
      first_name: nil,
      provider: nil,
      uuid: nil
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "get_user_by_uuid!/1 returns the user with given uuid" do
      user = user_fixture()
      assert Accounts.get_user_by_uuid!(user.uuid) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.avatar == "some avatar"
      assert user.email == "some email"
      assert user.first_name == "some first_name"
      assert user.provider == "some provider"
      assert user.uuid == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.avatar == "some updated avatar"
      assert user.email == "some updated email"
      assert user.first_name == "some updated first_name"
      assert user.provider == "some updated provider"
      assert user.uuid == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "contacts" do
    alias FocalApi.Accounts.Contact

    @valid_attrs %{
      best_time_to_contact: "some best_time_to_contact",
      email: "some@email",
      first_name: "some first_name",
      label: "some label",
      last_name: "some last_name",
      phone_number: "some phone_number",
      uuid: "7488a646-e31f-11e4-aace-600308960662"
    }
    @update_attrs %{
      best_time_to_contact: "some updated best_time_to_contact",
      email: "some@updated email",
      first_name: "some updated first_name",
      label: "some updated label",
      last_name: "some updated last_name",
      phone_number: "some updated phone_number",
      uuid: "7488a646-e31f-11e4-aace-600308960668"
    }
    @invalid_attrs %{
      best_time_to_contact: nil,
      email: nil,
      first_name: nil,
      label: nil,
      last_name: nil,
      phone_number: nil,
      uuid: nil
    }

    test "list_contacts/0 returns all contacts" do
      contact = TestHelpers.contact_fixture()
      assert Accounts.list_contacts() == [contact]
    end

    test "list_contacts_by_client/1 returns all contacts for a client" do
      client1 = TestHelpers.client_fixture()
      client2 = TestHelpers.client_fixture()

      contact1 = TestHelpers.contact_fixture(%{client_id: client1.id})
      _contact2 = TestHelpers.contact_fixture(%{client_id: client2.id})
      contact3 = TestHelpers.contact_fixture(%{client_id: client1.id})

      assert Accounts.list_contacts_by_client(client1.uuid) == [contact1, contact3]
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = TestHelpers.contact_fixture()
      assert Accounts.get_contact!(contact.id) == contact
    end

    test "create_contact/1 with valid data creates a contact" do
      assert {:ok, %Contact{} = contact} = Accounts.create_contact(@valid_attrs)
      assert contact.best_time_to_contact == "some best_time_to_contact"
      assert contact.email == "some@email"
      assert contact.first_name == "some first_name"
      assert contact.label == "some label"
      assert contact.last_name == "some last_name"
      assert contact.phone_number == "some phone_number"
      assert contact.uuid == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_contact(@invalid_attrs)
    end

    test "update_contact/2 with valid data updates the contact" do
      contact = TestHelpers.contact_fixture()
      assert {:ok, %Contact{} = contact} = Accounts.update_contact(contact, @update_attrs)
      assert contact.best_time_to_contact == "some updated best_time_to_contact"
      assert contact.email == "some@updated email"
      assert contact.first_name == "some updated first_name"
      assert contact.label == "some updated label"
      assert contact.last_name == "some updated last_name"
      assert contact.phone_number == "some updated phone_number"
      assert contact.uuid == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_contact/2 with invalid data returns error changeset" do
      contact = TestHelpers.contact_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_contact(contact, @invalid_attrs)
      assert contact == Accounts.get_contact!(contact.id)
    end

    test "delete_contact/1 deletes the contact" do
      contact = TestHelpers.contact_fixture()
      assert {:ok, %Contact{}} = Accounts.delete_contact(contact)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_contact!(contact.id) end
    end

    test "change_contact/1 returns a contact changeset" do
      contact = TestHelpers.contact_fixture()
      assert %Ecto.Changeset{} = Accounts.change_contact(contact)
    end
  end
end
