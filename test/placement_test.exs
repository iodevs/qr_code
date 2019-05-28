defmodule PlacementTest do
  @moduledoc false

  use ExUnit.Case
  # doctest QRCode

  alias MatrixReloaded.Matrix
  alias QRCode.Placement

  @timeout 300_000
  @moduletag timeout: @timeout

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

            Csv.read_file("finder_#{version}") == rv
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

            Csv.read_file("separator_#{version}") == rv
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

            Csv.read_file("reserved_area_#{version}") == rv
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

            Csv.read_file("timing_#{version}") == rv
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

            Csv.read_file("alignment_#{version}") == rv
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

            Csv.read_file("darkmodule_#{version}") == rv
          end)
        end

      assert tasks |> Enum.map(&Task.await(&1, @timeout)) |> Enum.all?()
    end
  end
end
