defmodule PhoenixSvgSprites.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_svg_sprites,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() in [:prod],
      deps: deps(),
      package: package(),
      description: "SVG sprite generator + component for Phoenix LiveView",
      source_url: "https://github.com/ArgyleWerewolf/phx-svg-sprites"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ArgyleWerewolf/phx-svg-sprites"}
    ]
  end
end
