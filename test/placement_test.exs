defmodule PlacementTest do
  @moduledoc false

  use ExUnit.Case
  # doctest QRCode

  alias MatrixReloaded.Matrix
  alias QRCode.Placement

  @timeout 300_000
  @moduletag timeout: @timeout
  @path_to_patterns "test/patterns/"
  @file_format ".csv"

  describe "Placement" do
    test "should check if finder patterns have correct position at qr matrix" do
      tasks =
        for version <- 1..40 do
          Task.async(fn ->
            size = 4 * version + 17

            rv =
              size
              |> Matrix.new()
              |> elem(1)
              |> Placement.add_finders(version)

            read_csv(version, "finder") == rv
          end)
        end

      assert tasks |> Enum.map(&Task.await(&1, @timeout)) |> Enum.all?()
    end

    test "should check if separator patterns have correct position at qr matrix" do
      tasks =
        for version <- 1..40 do
          Task.async(fn ->
            size = 4 * version + 17

            rv =
              size
              |> Matrix.new()
              |> elem(1)
              |> Placement.add_separators(version)

            read_csv(version, "separator") == rv
          end)
        end

      assert tasks |> Enum.map(&Task.await(&1, @timeout)) |> Enum.all?()
    end

    test "should check if reserved areas have correct position at qr matrix" do
      tasks =
        for version <- 1..40 do
          Task.async(fn ->
            size = 4 * version + 17

            rv =
              size
              |> Matrix.new()
              |> elem(1)
              |> Placement.add_reserved_areas(version, 1)

            read_csv(version, "reserved_area") == rv
          end)
        end

      assert tasks |> Enum.map(&Task.await(&1, @timeout)) |> Enum.all?()
    end

    test "should check if timing patterns have correct position at qr matrix" do
      tasks =
        for version <- 1..40 do
          Task.async(fn ->
            size = 4 * version + 17

            rv =
              size
              |> Matrix.new()
              |> elem(1)
              |> Placement.add_timings(version)

            read_csv(version, "timing") == rv
          end)
        end

      assert tasks |> Enum.map(&Task.await(&1, @timeout)) |> Enum.all?()
    end

    test "should check if alignment patterns have correct positions at qr matrix" do
      tasks =
        for version <- 1..40 do
          Task.async(fn ->
            size = 4 * version + 17

            rv =
              size
              |> Matrix.new()
              |> elem(1)
              |> Placement.add_alignments(version)

            read_csv(version, "alignment") == rv
          end)
        end

      assert tasks |> Enum.map(&Task.await(&1, @timeout)) |> Enum.all?()
    end

    test "should check if dark modules have correct position at qr matrix" do
      tasks =
        for version <- 1..40 do
          Task.async(fn ->
            size = 4 * version + 17

            rv =
              size
              |> Matrix.new()
              |> elem(1)
              |> Placement.add_dark_module(version)

            read_csv(version, "darkmodule") == rv
          end)
        end

      assert tasks |> Enum.map(&Task.await(&1, @timeout)) |> Enum.all?()
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
