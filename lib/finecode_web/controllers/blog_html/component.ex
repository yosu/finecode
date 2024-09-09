defmodule FinecodeWeb.Blog.Component do
  use FinecodeWeb, :html
  use Phoenix.Component

  attr :title, :string, required: true
  attr :posts, :list, required: true

  def posts(assigns) do
    ~H"""
    <section>
      <div class="container">
        <h2><%= @title %></h2>
        <%= for post <- @posts do %>
          <div class="row">
            <div class="column">
              <article class="post-list-item">
                <h3><%= link(post.title, to: ~p"/blog/#{post.id}") %></h3>
                <p><%= post.date %></p>
                <p><%= post.description %></p>
              </article>
            </div>
          </div>
        <% end %>
      </div>
    </section>
    """
  end
end
