defmodule GraphiteAggregator.MixProject do
  use Mix.Project

  def project do
    [
      app: :graphite_aggregator,
      version: "0.0.5",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "GraphiteAggregator",
      source_url: "https://github.com/StanAnsems/GraphiteAggregator"
    ]
  end

  def application, do: []

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Small graphite aggregator to push data each x time via UDP to graphite"
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/StanAnsems/GraphiteAggregator"}
    ]
  end
end
