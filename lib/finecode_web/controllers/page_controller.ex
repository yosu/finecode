defmodule FinecodeWeb.PageController do
  use FinecodeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def about(conn, _params) do
    render(conn, "about.html", page_title: "About - FineCode")
  end
end
