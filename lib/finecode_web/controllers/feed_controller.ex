defmodule FinecodeWeb.FeedController do
  use FinecodeWeb, :controller

  alias Finecode.Blog

  def atom(conn, _params) do
    render(conn, "atom.xml", posts: Blog.list_posts())
  end
end
