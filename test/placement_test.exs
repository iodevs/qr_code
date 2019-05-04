defmodule PlacementTest do
  @moduledoc false

  use ExUnit.Case, async: true
  # doctest QRCode

  alias MatrixReloaded.Matrix
  alias QRCode.Placement

  @moduletag timeout: 300_000
  @path_to_patterns "test/patterns/"
  @file_format ".csv"

  describe "Placement" do
    test "should check if finder patterns are correct at qr matrix" do
      result =
        for version <- 1..40 do
          size = 4 * version + 17

          rv =
            size
            |> Matrix.new()
            |> Placement.add_finders(version)

          version
          |> read_csv("finder")
          |> Kernel.==(rv)
        end

      assert Enum.all?(result)
    end

    test "should check if separator patterns are correct at qr matrix" do
      result =
        for version <- 1..40 do
          size = 4 * version + 17

          rv =
            size
            |> Matrix.new()
            |> Placement.add_separators(version)

          version
          |> read_csv("separator")
          |> Kernel.==(rv)
        end

      assert Enum.all?(result)
    end

    test "should check if reserved areas are correct at qr matrix" do
      result =
        for version <- 1..40 do
          size = 4 * version + 17

          rv =
            size
            |> Matrix.new()
            |> Placement.add_reserved_areas(version, 1)

          version
          |> read_csv("reserved_area")
          |> Kernel.==(rv)
        end

      assert Enum.all?(result)
    end

    test "should check if timing patterns are correct at qr matrix" do
      result =
        for version <- 1..40 do
          size = 4 * version + 17

          rv =
            size
            |> Matrix.new()
            |> Placement.add_timings(version)

          version
          |> read_csv("timing")
          |> Kernel.==(rv)
        end

      assert Enum.all?(result)
    end

    test "should check if alignment patterns are correct at qr matrix" do
      result =
        for version <- 1..40 do
          size = 4 * version + 17

          rv =
            size
            |> Matrix.new()
            |> Placement.add_alignments(version)

          version
          |> read_csv("alignment")
          |> Kernel.==(rv)
        end

      assert Enum.all?(result)
    end

    test "should check if dark modules are correct at qr matrix" do
      result =
        for version <- 1..40 do
          size = 4 * version + 17

          rv =
            size
            |> Matrix.new()
            |> Placement.add_dark_module(version)

          version
          |> read_csv("darkmodule")
          |> Kernel.==(rv)
        end

      assert Enum.all?(result)
    end
  end

  defp read_csv(version, type) do
    [@path_to_patterns, "pattern_", type, "_", Kernel.to_string(version), @file_format]
    |> Enum.join()
    |> CSVLixir.read()
    |> Enum.to_list()
    |> Enum.map(fn row -> row |> Enum.map(&String.to_integer/1) end)
    |> Result.ok()
  end
end
