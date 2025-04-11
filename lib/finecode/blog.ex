for app <- [:earmark, :makeup_elixir, :makeup_html, :makeup_eex, :makeup_syntect] do
  Application.ensure_all_started(app)
end

defmodule Finecode.Blog do
  alias Finecode.Blog.Post

  posts_paths = "posts/**/*.md" |> Path.wildcard() |> Enum.sort()

  posts =
    for post_path <- posts_paths do
      @external_resource Path.relative_to_cwd(post_path)
      Post.parse!(post_path)
    end

  @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

  def list_posts do
    @posts
  end

  def recent_posts do
    Enum.take(@posts, 5)
  end

  def post_by_id(id) do
    @posts |> Enum.find(&(&1.id == id))
  end
end
