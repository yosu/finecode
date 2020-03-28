defmodule FinecodeWeb.Router do
  use FinecodeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FinecodeWeb do
    pipe_through :browser

    get "/default", PageController, :default
    get "/", PageController, :index
    get "/about", PageController, :about
    get "/feeds/atom.xml", FeedController, :atom
  end

  scope "/blog", FinecodeWeb do
    pipe_through :browser

    get "/", BlogController, :index
    get "/:id", BlogController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", FinecodeWeb do
  #   pipe_through :api
  # end
end
