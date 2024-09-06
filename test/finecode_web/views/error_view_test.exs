defmodule FinecodeWeb.ErrorViewTest do
  use FinecodeWeb.ConnCase, async: true

  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(FinecodeWeb.ErrorView, "404", "html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(FinecodeWeb.ErrorView, "500", "html", []) == "Internal Server Error"
  end

  # use PentoWeb.ConnCase, async: true

  # # Bring render_to_string/4 for testing custom views
  # import Phoenix.Template

  # test "renders 404.html" do
  #   assert render_to_string(PentoWeb.ErrorHTML, "404", "html", []) == "Not Found"
  # end

  # test "renders 500.html" do
  #   assert render_to_string(PentoWeb.ErrorHTML, "500", "html", []) == "Internal Server Error"
  # end
end
