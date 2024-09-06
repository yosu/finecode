defmodule FinecodeWeb.FeedView do
  use FinecodeWeb, :html

  alias Finecode.Blog.Post

  def to_updated(%Post{} = post) do
    to_iso8601(post.date)
  end

  defp to_iso8601(%Date{} = date) do
    {:ok, naive_datetime} = NaiveDateTime.new(date, ~T[00:00:00])

    naive_datetime
    |> DateTime.from_naive!("Asia/Tokyo")
    |> DateTime.to_iso8601()
  end

  def feed_id() do
    tag_uri() <> ":feed"
  end

  def entry_id(%Post{} = post) do
    tag_uri() <> ":entry:#{post.id}"
  end

  defp tag_uri() do
    Application.fetch_env!(:finecode, :tag_uri)
  end

  embed_templates "../templates/feed/*"
end
