defmodule QRCode.MixProject do
  use Mix.Project

  @version "2.1.0"

  def project do
    [
      app: :qr_code,
      dialyzer: dialyzer_base() |> dialyzer_ptl(System.get_env("SEMAPHORE_CACHE_DIR")),
      version: @version,
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: "Library for generating QR code.",
      deps: deps(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      name: "QRCode",
      source_url: "https://github.com/iodevs/qr_code",
      docs: docs(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:result, "~> 1.3.0"},
      {:ex_maybe, "~> 1.1.1"},
      {:ex_doc, "~> 0.20.2", only: :dev},
      {:credo, "~> 1.1.0", only: [:dev, :test]},
      {:excoveralls, "~> 0.11.1", only: [:dev, :test]},
      {:inch_ex, "~> 2.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5.1", only: [:dev], runtime: false},
      {:xml_builder, "~> 2.1.1"},
      {:csvlixir, "~> 2.0.4"},
      {:matrix_reloaded, "~> 2.2.1"},
      {:propcheck, "~> 1.1", only: :test}
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

  defp dialyzer_base() do
    [
      plt_add_deps: :transitive,
      ignore_warnings: "dialyzer.ignore-warnings",
      flags: [
        :unmatched_returns,
        :error_handling,
        :race_conditions,
        :no_opaque
      ]
    ]
  end

  defp dialyzer_ptl(base, nil) do
    base
  end

  defp dialyzer_ptl(base, path) do
    base ++
      [
        plt_core_path: path,
        plt_file:
          Path.join(
            path,
            "dialyxir_erlang-#{otp_vsn()}_elixir-#{System.version()}_deps-dev.plt"
          )
      ]
  end

  defp otp_vsn() do
    major = :erlang.system_info(:otp_release) |> List.to_string()
    vsn_file = Path.join([:code.root_dir(), "releases", major, "OTP_VERSION"])

    try do
      {:ok, contents} = File.read(vsn_file)
      String.split(contents, "\n", trim: true)
    else
      [full] ->
        full

      _ ->
        major
    catch
      :error, _ ->
        major
    end
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
