defmodule Translator.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [app: :translator,
     version: @version,
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps, 

     # Hex
     description: description,
     package: package]
  end

  defp description do
    """
    Very simple model translation/globalization/localization library for Elixir inspired by globalize.
    """
  end

  defp package do
    [maintainers: ["Kenta Katsumata"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/kenta-aktsk/translator"},
     files: ~w(mix.exs README.md LICENSE lib)]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:ecto, "~> 2.0.0-beta"},
     {:ex_doc, "~> 0.11", only: :docs}]
  end
end
