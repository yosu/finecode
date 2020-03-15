defmodule Finecode.Blog do
  alias Finecode.Blog.Post

  posts_paths = "posts/**/*.md" |> Path.wildcard() |> Enum.sort()

  posts =
    for post_path <- posts_paths do
      @external_resource Path.relative_to_cwd(post_path)
      Post.parse!(post_path)
    end

  @posts posts

  def posts do
    @posts
  end
end
