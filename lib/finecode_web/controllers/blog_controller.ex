defmodule FinecodeWeb.BlogController do
  use FinecodeWeb, :controller

  alias Finecode.Blog

  def index(conn, _params) do
    render(conn, "index.html", posts: Blog.list_posts())
  end
end
