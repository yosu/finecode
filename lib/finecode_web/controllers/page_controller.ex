defmodule FinecodeWeb.PageController do
  use FinecodeWeb, :controller

  def default(conn, _params) do
    render(conn, "default.html")
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
