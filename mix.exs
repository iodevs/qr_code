defmodule QRCode.MixProject do
  use Mix.Project

  def project do
    [
      app: :qr_code,
      dialyzer: dialyzer_base() |> dialyzer_ptl(System.get_env("SEMAPHORE_CACHE_DIR")),
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: "Library for generating QR code.",
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
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
      {:result, "~> 1.1"},
      {:ex_maybe, "~> 1.0"},
      {:ex_doc, "~> 0.18.1", only: :dev},
      {:credo, "~> 0.9", only: [:dev, :test]},
      {:excoveralls, "~> 0.9", only: :test},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:xml_builder, "~> 2.1.1"},
      {:csvlixir, "~> 2.0.3"},
      {:matrix_reloaded, "~> 2.0.0"}
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
end
