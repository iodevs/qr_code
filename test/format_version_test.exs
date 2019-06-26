defmodule FormatVersionTest do
  @moduledoc false

  use ExUnit.Case
  # doctest QRCode

  use ExUnit.Case
  use PropCheck

  alias MatrixReloaded.{Matrix, Vector}
  alias QRCode.{FormatVersion, QR}
  alias Generators.QR, as: QRGenerator

  @format_information %{
    low: %{
      0 => [1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0],
      1 => [1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1],
      2 => [1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0],
      3 => [1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1],
      4 => [1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1],
      5 => [1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0],
      6 => [1, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
      7 => [1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0]
    },
    medium: %{
      0 => [1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0],
      1 => [1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1],
      2 => [1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0],
      3 => [1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1],
      4 => [1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1],
      5 => [1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0],
      6 => [1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1],
      7 => [1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0]
    },
    quartile: %{
      0 => [0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1],
      1 => [0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0],
      2 => [0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1],
      3 => [0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0],
      4 => [0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0],
      5 => [0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1],
      6 => [0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0],
      7 => [0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1]
    },
    high: %{
      0 => [0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1],
      1 => [0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0],
      2 => [0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1],
      3 => [0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0],
      4 => [0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0],
      5 => [0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1],
      6 => [0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0],
      7 => [0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1]
    }
  }

  @version_information %{
    7 => [[0, 0, 1], [0, 1, 0], [0, 1, 0], [0, 1, 1], [1, 1, 1], [0, 0, 0]],
    8 => [[0, 0, 1], [1, 1, 1], [0, 1, 1], [0, 1, 0], [0, 0, 0], [1, 0, 0]],
    9 => [[1, 0, 0], [1, 1, 0], [0, 1, 0], [1, 0, 1], [1, 0, 0], [1, 0, 0]],
    10 => [[1, 1, 0], [0, 1, 0], [1, 1, 0], [0, 1, 0], [0, 1, 0], [1, 0, 0]],
    11 => [[0, 1, 1], [0, 1, 1], [1, 1, 1], [1, 0, 1], [1, 1, 0], [1, 0, 0]],
    12 => [[0, 1, 0], [0, 0, 1], [1, 0, 1], [1, 1, 0], [0, 0, 1], [1, 0, 0]],
    13 => [[1, 1, 1], [0, 0, 0], [1, 0, 0], [0, 0, 1], [1, 0, 1], [1, 0, 0]],
    14 => [[1, 0, 1], [1, 0, 0], [0, 0, 0], [1, 1, 0], [0, 1, 1], [1, 0, 0]],
    15 => [[0, 0, 0], [1, 0, 1], [0, 0, 1], [0, 0, 1], [1, 1, 1], [1, 0, 0]],
    16 => [[0, 0, 0], [1, 1, 1], [1, 0, 1], [1, 0, 1], [0, 0, 0], [0, 1, 0]],
    17 => [[1, 0, 1], [1, 1, 0], [1, 0, 0], [0, 1, 0], [1, 0, 0], [0, 1, 0]],
    18 => [[1, 1, 1], [0, 1, 0], [0, 0, 0], [1, 0, 1], [0, 1, 0], [0, 1, 0]],
    19 => [[0, 1, 0], [0, 1, 1], [0, 0, 1], [0, 1, 0], [1, 1, 0], [0, 1, 0]],
    20 => [[0, 1, 1], [0, 0, 1], [0, 1, 1], [0, 0, 1], [0, 0, 1], [0, 1, 0]],
    21 => [[1, 1, 0], [0, 0, 0], [0, 1, 0], [1, 1, 0], [1, 0, 1], [0, 1, 0]],
    22 => [[1, 0, 0], [1, 0, 0], [1, 1, 0], [0, 0, 1], [0, 1, 1], [0, 1, 0]],
    23 => [[0, 0, 1], [1, 0, 1], [1, 1, 1], [1, 1, 0], [1, 1, 1], [0, 1, 0]],
    24 => [[0, 0, 1], [0, 0, 0], [1, 1, 0], [1, 1, 1], [0, 0, 0], [1, 1, 0]],
    25 => [[1, 0, 0], [0, 0, 1], [1, 1, 1], [0, 0, 0], [1, 0, 0], [1, 1, 0]],
    26 => [[1, 1, 0], [1, 0, 1], [0, 1, 1], [1, 1, 1], [0, 1, 0], [1, 1, 0]],
    27 => [[0, 1, 1], [1, 0, 0], [0, 1, 0], [0, 0, 0], [1, 1, 0], [1, 1, 0]],
    28 => [[0, 1, 0], [1, 1, 0], [0, 0, 0], [0, 1, 1], [0, 0, 1], [1, 1, 0]],
    29 => [[1, 1, 1], [1, 1, 1], [0, 0, 1], [1, 0, 0], [1, 0, 1], [1, 1, 0]],
    30 => [[1, 0, 1], [0, 1, 1], [1, 0, 1], [0, 1, 1], [0, 1, 1], [1, 1, 0]],
    31 => [[0, 0, 0], [0, 1, 0], [1, 0, 0], [1, 0, 0], [1, 1, 1], [1, 1, 0]],
    32 => [[1, 0, 1], [0, 1, 0], [1, 1, 1], [0, 0, 1], [0, 0, 0], [0, 0, 1]],
    33 => [[0, 0, 0], [0, 1, 1], [1, 1, 0], [1, 1, 0], [1, 0, 0], [0, 0, 1]],
    34 => [[0, 1, 0], [1, 1, 1], [0, 1, 0], [0, 0, 1], [0, 1, 0], [0, 0, 1]],
    35 => [[1, 1, 1], [1, 1, 0], [0, 1, 1], [1, 1, 0], [1, 1, 0], [0, 0, 1]],
    36 => [[1, 1, 0], [1, 0, 0], [0, 0, 1], [1, 0, 1], [0, 0, 1], [0, 0, 1]],
    37 => [[0, 1, 1], [1, 0, 1], [0, 0, 0], [0, 1, 0], [1, 0, 1], [0, 0, 1]],
    38 => [[0, 0, 1], [0, 0, 1], [1, 0, 0], [1, 0, 1], [0, 1, 1], [0, 0, 1]],
    39 => [[1, 0, 0], [0, 0, 0], [1, 0, 1], [0, 1, 0], [1, 1, 1], [0, 0, 1]],
    40 => [[1, 0, 0], [1, 0, 1], [1, 0, 0], [0, 1, 1], [0, 0, 0], [1, 0, 1]]
  }

  @tag timeout: 120_000
  property "should check if format string has correct position at qr matrix" do
    forall qr <- qr() do
      {:ok, q} = FormatVersion.put_information(qr)

      check_format(q)
    end
  end

  @tag timeout: 120_000
  property "should check if version patterns have correct position at qr matrix" do
    forall qr <- qr() do
      {:ok, q} = FormatVersion.put_information(qr)

      check_version(q) and check_format(q)
    end
  end

  # Helpers

  defp check_format(%QR{matrix: matrix, ecc_level: level, mask_num: mask_num}) do
    expected_format = @format_information[level][mask_num]

    {size, _} = Matrix.size(matrix)

    {:ok, {_, row_left}} =
      matrix
      |> Matrix.get_row({8, 0}, 9)
      |> Result.map(&List.pop_at(&1, -3))

    {:ok, {_, col_top}} =
      matrix
      |> Matrix.get_col({0, 8}, 8)
      |> Result.map(&List.pop_at(&1, -2))

    row_top =
      col_top
      |> Vector.transpose()
      |> Enum.reverse()

    {:ok, col_bottom} =
      matrix
      |> Matrix.get_col({size - 7, 8}, 7)
      |> Result.map(&Vector.transpose/1)
      |> Result.map(&Enum.reverse/1)

    {:ok, row_right} = Matrix.get_row(matrix, {8, size - 8}, 8)

    expected_format == row_left ++ row_top and expected_format == col_bottom ++ row_right
  end

  defp check_version(%QR{matrix: matrix, version: version})
       when version < 7 do
    {:ok, expected_matrix} = (4 * version + 17) |> Matrix.new()

    {:ok, mat} =
      matrix
      |> Matrix.update_row(Vector.row(9), {8, 0})
      |> Result.and_then(&Matrix.update_row(&1, Vector.row(8), {8, 4 * version + 9}))
      |> Result.and_then(&Matrix.update_col(&1, Vector.col(9), {0, 8}))
      |> Result.and_then(&Matrix.update_col(&1, Vector.col(7), {4 * version + 10, 8}))

    expected_matrix == mat
  end

  defp check_version(%QR{matrix: matrix, version: version}) do
    expected_info = @version_information[version]

    {size, _} = Matrix.size(matrix)

    {:ok, left_down} =
      matrix
      |> Matrix.get_submatrix({size - 11, 0}, {size - 9, 5})
      |> Result.map(&Matrix.transpose/1)

    {:ok, right_top} =
      matrix
      |> Matrix.get_submatrix({0, size - 11}, {5, size - 9})

    expected_info == left_down and expected_info == right_top
  end

  # Generators

  defp qr() do
    let {level, version, mask_num} <-
          {QRGenerator.level(), QRGenerator.version(), range(0, 7)} do
      {:ok, matrix} = (4 * version + 17) |> Matrix.new()

      %QR{
        ecc_level: level,
        version: version,
        mask_num: mask_num,
        matrix: matrix
      }
    end
  end
end
