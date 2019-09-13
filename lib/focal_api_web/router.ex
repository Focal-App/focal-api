defmodule FocalApiWeb.Router do
  use FocalApiWeb, :router

  pipeline :auth do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug FocalApi.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug FocalApi.Plugs.SetUser
  end

  scope "/api", FocalApiWeb do
    pipe_through :api

    get "/client/:client_uuid/packages", PackageController, :index_by_client
    post "/client/:client_uuid/package", PackageController, :create
    get "/package/:package_uuid", PackageController, :show
    put "/package/:package_uuid", PackageController, :update
    delete "/package/:package_uuid", PackageController, :delete

    get "/package/:package_uuid/events", EventController, :index_by_package
    post "/package/:package_uuid/event", EventController, :create
    get "/event/:event_uuid", EventController, :show
    put "/event/:event_uuid", EventController, :update
    delete "/event/:event_uuid", EventController, :delete

    get "/client/:client_uuid/tasks", TaskController, :index_by_client
    post "/client/:client_uuid/task", TaskController, :create
    get "/task/:task_uuid", TaskController, :show
    put "/task/:task_uuid", TaskController, :update
    delete "/task/:task_uuid", TaskController, :delete

    get "/user/:user_uuid/clients", ClientController, :index_by_user
    resources "/client", ClientController, only: [:show, :create, :update, :delete], param: "client_uuid"

    get "/users", UserController, :index
    resources "/user", UserController, only: [:show, :create], param: "user_uuid"
  end

  scope "/auth", FocalApiWeb do
    pipe_through :auth

    get "/signout", SessionController, :delete
    get "/:provider", SessionController, :request
    get "/:provider/callback", SessionController, :create
  end
end
