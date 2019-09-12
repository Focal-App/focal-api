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

    resources "/clients", ClientController, only: [:show, :create, :update, :delete], param: "client_uuid"
    resources "/users", UserController, only: [:show, :index, :create], param: "user_uuid"
    get "/users/:user_uuid/clients", ClientController, :index_by_user
  end

  scope "/auth", FocalApiWeb do
    pipe_through :auth

    get "/signout", SessionController, :delete
    get "/:provider", SessionController, :request
    get "/:provider/callback", SessionController, :create
  end
end
