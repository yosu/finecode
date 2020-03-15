defmodule FinecodeWeb.BlogController do
  use FinecodeWeb, :controller

  alias Finecode.Blog
  alias FinecodeWeb.ErrorView

  def index(conn, _params) do
    render(conn, "index.html", posts: Blog.list_posts())
  end

  def show(conn, params) do
    case Blog.post_by_id(params["id"]) do
      nil ->
        # TODO: かわいい & 助けになるエラーページにする
        conn
        |> put_status(:not_found)
        |> put_view(ErrorView)
        |> render(:"404")
      post ->
        render(conn, "show.html", post: post)
    end
  end
end
