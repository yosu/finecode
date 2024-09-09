defmodule FinecodeWeb.BlogHTML do
  use FinecodeWeb, :html
  import FinecodeWeb.Blog.Component

  embed_templates "blog_html/*"
end
