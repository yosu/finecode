defmodule FinecodeWeb.PageController do
  use FinecodeWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def about(conn, _params) do
    render(conn, :about, page_title: "About - FineCode")
  end
end
