defmodule FocalApiWeb.EmailView do
  use FocalApiWeb, :view

  def render("show.json", %{email_result: email_result}) do
    # TODO change so it doesnt need to rely on strings everytime we look at api result data
    %{
      data: %{
        email_id: email_result["id"]
      }
    }
  end
end
