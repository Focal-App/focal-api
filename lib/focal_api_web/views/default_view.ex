defmodule FocalApiWeb.DefaultView do
  use FocalApiWeb, :view

  def render("show.json", %{value: value}) do
    %{data: value}
  end

end
