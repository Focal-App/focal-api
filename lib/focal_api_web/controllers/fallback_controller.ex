defmodule FocalApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use FocalApiWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(FocalApiWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :api_errors, errors}) do
    conn
    |> put_status(errors["code"])
    |> put_view(FocalApiWeb.ErrorView)
    |> render("external_api_error.json", errors: errors)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(FocalApiWeb.ErrorView)
    |> render(:"404")
  end
end
