defmodule FinecodeWeb.PageHTML do
  use FinecodeWeb, :html
  import FinecodeWeb.Blog.Component

  embed_templates "page_html/*"
end
