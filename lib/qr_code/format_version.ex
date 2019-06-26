defmodule QRCode.FormatVersion do
  @moduledoc """
  A QR code uses error correction encoding and mask patterns. The QR code's
  size is represented by a number, called a version number. To ensure that
  a QR code scanner accurately decodes what it scans, the QR code specification
  requires that each code include a format information string, which tells the
  QR code scanner which error correction level and mask pattern the QR code
  is using. In addition, for version 7 and larger, the QR code specification
  requires that each code include a version information string, which tells
  the QR code scanner which version the code is.
  """
  alias MatrixReloaded.{Matrix, Vector}
  alias QRCode.QR
  import QRCode.QR, only: [masking: 1, version: 1]

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

  @spec put_information(QR.t()) :: Result.t(String.t(), QR.t())
  def put_information(
        %QR{matrix: matrix, version: version, ecc_level: ecc_level, mask_num: mask_num} = qr
      )
      when masking(mask_num) and version(version) do
    matrix
    |> set_format_info(ecc_level, mask_num, version)
    |> Result.and_then(&set_version_info(&1, version))
    |> Result.map(fn matrix -> %{qr | matrix: matrix} end)
  end

  @spec set_format_info(Matrix.t(), QR.level(), QR.mask_num(), QR.version()) ::
          Result.t(String.t(), Matrix.t())
  def set_format_info(matrix, table_level, mask_num, version) do
    {row_left, row_right, col_top, col_bottom} = information_string(table_level, mask_num)

    matrix
    |> Matrix.update_row(row_left, {8, 0})
    |> Result.and_then(&Matrix.update_row(&1, row_right, {8, 4 * version + 9}))
    |> Result.and_then(&Matrix.update_col(&1, col_top, {0, 8}))
    |> Result.and_then(&Matrix.update_col(&1, col_bottom, {4 * version + 10, 8}))
  end

  @spec set_version_info(Matrix.t(), QR.version()) :: Result.t(String.t(), Matrix.t())
  def set_version_info(matrix, version) when version < 7 do
    Result.ok(matrix)
  end

  def set_version_info(matrix, version) do
    version_info = @version_information[version]

    matrix
    |> Matrix.update(version_info, {0, 4 * version + 6})
    |> Result.and_then(&Matrix.update(&1, Matrix.transpose(version_info), {4 * version + 6, 0}))
  end

  defp information_string(level, mask_num) do
    row = @format_information[level][mask_num]

    row_left =
      row
      |> Enum.take(7)
      |> List.pop_at(-1)
      |> (fn {last, first} -> first ++ [0, last] end).()

    row_right = row |> Enum.drop(7)

    col_top =
      row_right
      |> Enum.split(2)
      |> (fn {first, rest} -> first ++ [0 | rest] end).()
      |> Enum.reverse()
      |> Vector.transpose()

    col_bottom =
      row
      |> Enum.take(7)
      |> Enum.reverse()
      |> Vector.transpose()

    {row_left, row_right, col_top, col_bottom}
  end
end
