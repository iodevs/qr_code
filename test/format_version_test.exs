defmodule FormatVersionTest do
  @moduledoc false

  use ExUnit.Case
  # doctest QRCode

  alias MatrixReloaded.Matrix
  alias QRCode.FormatVersion

  @timeout 300_000
  @moduletag timeout: @timeout
  @path_to_patterns "test/patterns/"
  @file_format ".csv"

  describe "FormatVersion" do
    test "should check if format patterns have correct position at qr matrix" do
      tasks =
        for ecc_level <- ["L", "M", "Q", "H"], version <- 1..6, mask_num <- 0..7 do
          Task.async(fn ->
            file_name =
              [
                @path_to_patterns,
                "pattern_format_#{ecc_level}_#{version}_mp_#{mask_num}",
                @file_format
              ]
              |> Enum.join()

            size = 4 * version + 17

            rv =
              size
              |> Matrix.new()
              |> elem(1)
              |> FormatVersion.set_format_info(convert(ecc_level), mask_num, version)

            read_csv(file_name) == rv
          end)
        end

      assert tasks |> Enum.map(&Task.await(&1, @timeout)) |> Enum.all?()
    end

    test "should check if version patterns have correct position at qr matrix" do
      tasks =
        for version <- 7..40 do
          Task.async(fn ->
            size = 4 * version + 17

            rv =
              size
              |> Matrix.new()
              |> elem(1)
              |> FormatVersion.set_version_info(version)

            file_name =
              [@path_to_patterns, "pattern_version_#{version}", @file_format]
              |> Enum.join()

            read_csv(file_name) == rv
          end)
        end

      assert tasks |> Enum.map(&Task.await(&1, @timeout)) |> Enum.all?()
    end
  end

  defp convert("L") do
    :low
  end

  defp convert("M") do
    :medium
  end

  defp convert("Q") do
    :quartile
  end

  defp convert("H") do
    :high
  end

  defp read_csv(file_name) do
    file_name
    |> File.stream!()
    |> Stream.map(&String.trim(&1))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn row -> row |> Stream.map(&String.to_integer/1) |> Enum.to_list() end)
    |> Enum.to_list()
    |> Result.ok()
  end
end
