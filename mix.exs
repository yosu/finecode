defmodule Finecode.MixProject do
  use Mix.Project

  def project do
    [
      app: :finecode,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Finecode.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_view, "~> 0.18.18"},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.1"},
      {:earmark, "~> 1.4"},
      {:makeup, "~> 1.2.1"},
      {:makeup_elixir, "~> 1.0.0"},
      {:makeup_eex, "~> 2.0"},
      {:makeup_html, "~> 0.1.0"},
      {:makeup_syntect, "~> 0.1"},
      {:tz, "~> 0.3.0"}
    ]
  end

  defp aliases do
    [
      "assets.deploy": ["esbuild default --minify --loader:.jpg=file", "phx.digest"]
    ]
  end
end
