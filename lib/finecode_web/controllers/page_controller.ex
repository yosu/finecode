defmodule FinecodeWeb.PageController do
  use FinecodeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
