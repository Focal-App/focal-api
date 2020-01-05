defmodule FocalApiWeb.UserView do
  use FocalApiWeb, :view
  alias FocalApiWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      avatar: user.avatar,
      email: user.email,
      first_name: user.first_name,
      provider: user.provider,
      uuid: user.uuid
    }
  end
end
