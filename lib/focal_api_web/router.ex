defmodule FocalApiWeb.Router do
  use FocalApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", FocalApiWeb do
    pipe_through :api
  end
end
