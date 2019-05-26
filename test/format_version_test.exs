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
    # test "should check if format patterns have correct position at qr matrix" do
    #   tasks =
    #     for version <- 1..6 do
    #       Task.async(fn ->
    #         size = 4 * version + 17

    #         # ecc_level = L,M,Q,H
    #         # mask_num = 0..7
    #         # version = 1..6
    #         rv =
    #           size
    #           |> Matrix.new()
    #           |> elem(1)
    #           |> FormatVersion.set_format_info(ecc_level, mask_num, version)

    #         read_csv(version, "format_info") == rv
    #       end)
    #     end

    #   assert tasks |> Enum.map(&Task.await(&1, @timeout)) |> Enum.all?()
    # end

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

            read_csv(version, "version") == rv
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
