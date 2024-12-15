defmodule PlacementTest do
  @moduledoc false

  use ExUnit.Case
  use PropCheck

  alias MatrixReloaded.Matrix
  alias QRCode.{Placement, QR, ErrorCorrection}
  alias Generators.QR, as: QRGenerator

  @timeout 300_000
  @moduletag timeout: 180_000

  @tag timeout: 180_000
  describe "Placement" do
    test "should check if finder patterns have correct position at qr matrix" do
      tasks =
        for version <- 1..40//1 do
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
        for version <- 1..40//1 do
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
        for version <- 1..40//1 do
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
        for version <- 1..40//1 do
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
        for version <- 1..40//1 do
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
        for version <- 1..40//1 do
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

  @tag timeout: 300_000
  property "should check if filled matrix by message is correct" do
    forall qr <- qr() do
      {:ok, q} = Placement.put_patterns(qr)

      check_fill_matrix_by_message(q)
    end
  end

  # Helpers

  defp check_fill_matrix_by_message(%QR{matrix: matrix, message: message, version: version}) do
    size = 4 * version + 16

    {:ok, [hd | rest]} =
      size..7//-1
      |> Enum.take_every(2)
      |> Enum.concat([5, 3, 1])
      |> Enum.reverse()
      |> Enum.map(fn c ->
        [Matrix.get_col(matrix, c - 1), Matrix.get_col(matrix, c)]
        |> Result.fold()
        |> Result.map(&Enum.map(&1, fn e -> List.flatten(e) end))
        |> Result.map(&Enum.zip/1)
        |> Result.map(&Enum.map(&1, fn e -> Tuple.to_list(e) end))
      end)
      |> Result.fold()
      |> Result.map(&Enum.with_index/1)
      |> Result.map(
        &Enum.map(&1, fn
          {col, idx} when rem(idx, 2) == 1 -> Enum.reverse(col)
          {col, _idx} -> col
        end)
      )

    expected_msg =
      rest
      |> Enum.reduce(hd, fn c, acc -> Enum.concat(c, acc) end)
      |> Enum.reduce(<<>>, fn
        [left, right], acc when left < 2 and right < 2 ->
          <<acc::bitstring, right::size(1), left::size(1)>>

        [left, _right], acc when left < 2 ->
          <<acc::bitstring, left::size(1)>>

        [_left, right], acc when right < 2 ->
          <<acc::bitstring, right::size(1)>>

        _, acc ->
          acc
      end)

    expected_msg == message
  end

  # Generators

  defp qr() do
    let {level, version} <- {QRGenerator.level(), QRGenerator.version()} do
      qr = %QR{
        ecc_level: level,
        version: version
      }

      count = ErrorCorrection.total_data_codewords(qr)

      %QR{qr | encoded: :crypto.strong_rand_bytes(count)}
      |> QRCode.ErrorCorrection.put()
      |> QRCode.Message.put()
    end
  end
end
