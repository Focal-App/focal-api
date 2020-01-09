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

    get "/clients/:client_uuid/packages", PackageController, :index_by_client
    post "/clients/:client_uuid/packages", PackageController, :create
    get "/packages/:package_uuid", PackageController, :show
    put "/packages/:package_uuid", PackageController, :update
    delete "/packages/:package_uuid", PackageController, :delete

    get "/packages/:package_uuid/events", EventController, :index_by_package
    post "/packages/:package_uuid/events", EventController, :create
    get "/events/:event_uuid", EventController, :show
    put "/events/:event_uuid", EventController, :update
    delete "/events/:event_uuid", EventController, :delete

    get "/clients/:client_uuid/tasks", TaskController, :index_by_client
    post "/clients/:client_uuid/tasks", TaskController, :create
    get "/tasks/:task_uuid", TaskController, :show
    put "/tasks/:task_uuid", TaskController, :update
    delete "/tasks/:task_uuid", TaskController, :delete

    get "/clients/:client_uuid/workflows", WorkflowController, :index_by_client
    post "/clients/:client_uuid/workflows", WorkflowController, :create
    get "/workflows/:workflow_uuid", WorkflowController, :show
    put "/workflows/:workflow_uuid", WorkflowController, :update
    delete "/workflows/:workflow_uuid", WorkflowController, :delete

    get "/clients/:client_uuid/data", ClientController, :show_all_client_data
    get "/users/:user_uuid/clients", ClientController, :index_by_user
    get "/users/:user_uuid/clients/data", ClientController, :index_of_all_client_data_by_user
    resources "/clients", ClientController, only: [:show, :create, :update, :delete], param: "client_uuid"

    get "/users", UserController, :index
    resources "/users", UserController, only: [:show, :create], param: "user_uuid"

    resources "/templates", TemplateController, except: [:new, :edit], param: "template_uuid"
  end

  scope "/auth", FocalApiWeb do
    pipe_through :auth

    get "/signout", SessionController, :delete
    get "/:provider", SessionController, :request
    get "/:provider/callback", SessionController, :create
  end
end
