defmodule FocalApiWeb.Router do
  use FocalApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", FocalApiWeb do
    pipe_through :api

    resources "/clients", ClientController, only: [:index, :show, :create, :update, :delete], param: "uuid"
    resources "/users", UserController, only: [:show, :create], param: "uuid"
  end
end
