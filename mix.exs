defmodule QRCode.MixProject do
  use Mix.Project

  @version "2.3.0"

  def project do
    [
      aliases: aliases(),
      app: :qr_code,
      deps: deps(),
      description: "Library for generating QR code.",
      dialyzer: dialyzer(),
      docs: docs(),
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "QRCode",
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      source_url: "https://github.com/iodevs/qr_code",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: @version
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Private

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test]},
      {:csvlixir, "~> 2.0.4", only: [:dev, :test]},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.28", only: :dev},
      {:ex_maybe, "~> 1.1.1"},
      {:excoveralls, "~> 0.14", only: [:dev, :test]},
      {:inch_ex, "~> 2.0", only: [:dev, :test], runtime: false},
      {:matrix_reloaded, "~> 2.2.1"},
      {:propcheck, "~> 1.4", only: :test},
      {:result, "~> 1.7", override: true},
      {:xml_builder, "~> 2.2"}
    ]
  end

  defp package do
    [
      maintainers: [
        "Jindrich K. Smitka <smitka.j@gmail.com>",
        "Ondrej Tucek <ondrej.tucek@gmail.com>"
      ],
      licenses: ["BSD-4-Clause"],
      links: %{
        "GitHub" => "https://github.com/iodevs/qr_code"
      }
    ]
  end

  defp aliases() do
    [
      docs: ["docs", &copy_assets/1]
    ]
  end

  defp dialyzer() do
    [
      plt_add_apps: [:mix, :ex_unit],
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      ignore_warnings: "dialyzer.ignore-warnings",
      flags: [
        :unmatched_returns,
        :error_handling,
        :race_conditions,
        :no_opaque
      ]
    ]
  end

  defp docs() do
    [
      source_ref: "v#{@version}",
      canonical: "https://hexdocs.pm/qr_code",
      main: "readme",
      extras: ["README.md"],
      groups_for_extras: [
        Introduction: ~r/README.md/
      ]
    ]
  end

  defp copy_assets(_) do
    File.mkdir_p!("doc/docs")
    File.cp_r!("docs", "doc/docs")
  end
end
