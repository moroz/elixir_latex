defmodule ElixirLatex.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_latex,
      version: "0.1.2-alpha1",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      licenses: ["BSD-3"],
      description:
        "Renders LaTeX source files using the Phoenix templating engine, handles attachments, compiles everything as PDF using (Xe)LaTeX.",
      links: %{
        "Github" => "https://github.com/moroz/elixir_latex"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mime, "~> 1.5"},
      {:phoenix, ">= 1.3.0"},

      # Hex
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
