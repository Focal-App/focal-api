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

  describe "events" do
    alias FocalApi.Clients.Event

    @valid_attrs %{event_name: "some event_name", shoot_date: "2010-04-17T14:00:00Z", uuid: "7488a646-e31f-11e4-aace-600308960662"}
    @update_attrs %{event_name: "some updated event_name", shoot_date: "2011-05-18T15:01:01Z", uuid: "7488a646-e31f-11e4-aace-600308960668"}
    @invalid_attrs %{event_name: nil, shoot_date: nil, uuid: nil}

    def event_fixture(attrs \\ %{}) do
      {:ok, event} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Clients.create_event()

      event
    end

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Clients.list_events() == [event]
    end

    test "list_events_by_package/1 returns all packages for a event" do
      package1 = TestHelpers.package_fixture()
      package2 = TestHelpers.package_fixture()

      event1 = event_fixture(%{ package_id: package1.id })
      _event2 = event_fixture(%{ package_id: package2.id })
      event3 = event_fixture(%{ package_id: package1.id })

      assert Clients.list_events_by_package(package1.uuid) == [event1, event3]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Clients.get_event!(event.id) == event
    end

    test "get_event_by_uuid!/1 returns the event with given uuid" do
      event = event_fixture()
      assert Clients.get_event_by_uuid!(event.uuid) == event
    end

    test "create_event/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = Clients.create_event(@valid_attrs)
      assert event.event_name == "some event_name"
      assert event.shoot_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert event.uuid == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      assert {:ok, %Event{} = event} = Clients.update_event(event, @update_attrs)
      assert event.event_name == "some updated event_name"
      assert event.shoot_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert event.uuid == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.update_event(event, @invalid_attrs)
      assert event == Clients.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Clients.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Clients.change_event(event)
    end
  end

  describe "tasks" do
    alias FocalApi.Clients.Task

    @valid_attrs %{category: "some category", is_completed: true, step: "some step", uuid: "7488a646-e31f-11e4-aace-600308960662"}
    @update_attrs %{category: "some updated category", is_completed: false, step: "some updated step", uuid: "7488a646-e31f-11e4-aace-600308960668"}
    @invalid_attrs %{category: nil, is_completed: nil, step: nil, uuid: nil}

    def task_fixture(attrs \\ %{}) do
      {:ok, task} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Clients.create_task()

      task
    end

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Clients.list_tasks() == [task]
    end

    test "list_tasks_by_event/1 returns all tasks for a event" do
      event1 = TestHelpers.event_fixture()
      event2 = TestHelpers.event_fixture()

      task1 = task_fixture(%{ event_id: event1.id })
      _task2 = task_fixture(%{ event_id: event2.id })
      task3 = task_fixture(%{ event_id: event1.id })

      assert Clients.list_tasks_by_event(event1.uuid) == [task1, task3]
    end

    test "list_tasks_by_client/1 returns all tasks for a client" do
      client1 = TestHelpers.client_fixture()
      client2 = TestHelpers.client_fixture()

      task1 = task_fixture(%{ client_id: client1.id })
      _task2 = task_fixture(%{ client_id: client2.id })
      task3 = task_fixture(%{ client_id: client1.id })

      assert Clients.list_tasks_by_client(client1.uuid) == [task1, task3]
    end

    test "list_first_uncompleted_task_by_client/1 returns first uncomplete task for a client" do
      client1 = TestHelpers.client_fixture()

      _task1 = task_fixture(%{ client_id: client1.id, is_completed: true })
      task2 = task_fixture(%{ client_id: client1.id, is_completed: false })

      assert Clients.list_first_uncompleted_task_by_client(client1.uuid) == [task2]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Clients.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      assert {:ok, %Task{} = task} = Clients.create_task(@valid_attrs)
      assert task.category == "some category"
      assert task.is_completed == true
      assert task.step == "some step"
      assert task.uuid == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      assert {:ok, %Task{} = task} = Clients.update_task(task, @update_attrs)
      assert task.category == "some updated category"
      assert task.is_completed == false
      assert task.step == "some updated step"
      assert task.uuid == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.update_task(task, @invalid_attrs)
      assert task == Clients.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Clients.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Clients.change_task(task)
    end
  end
end
