defmodule FinecodeWeb.PageController do
  use FinecodeWeb, :controller
  alias Finecode.Blog

  def index(conn, _params) do
    render(conn, :index, recent_posts: Blog.recent_posts())
  end

  def about(conn, _params) do
    render(conn, :about, page_title: "About - FineCode")
  end
end
