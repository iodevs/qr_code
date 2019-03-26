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
  alias QRCode.{QR, Utils}
  import QRCode.QR, only: [masking: 1, version: 1]

  @low [
    [1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0],
    [1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1],
    [1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0],
    [1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1],
    [1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1],
    [1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0],
    [1, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
    [1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0]
  ]

  @medium [
    [1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0],
    [1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1],
    [1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0],
    [1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1],
    [1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0],
    [1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1],
    [1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0]
  ]

  @quartile [
    [0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1],
    [0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1],
    [0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0],
    [0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0],
    [0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1],
    [0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0],
    [0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1]
  ]

  @high [
    [0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1],
    [0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1],
    [0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0],
    [0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1],
    [0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0],
    [0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1]
  ]

  @version_table [
    [[0, 0, 1], [0, 1, 0], [0, 1, 0], [0, 1, 1], [1, 1, 1], [0, 0, 0]],
    [[0, 0, 1], [1, 1, 1], [0, 1, 1], [0, 1, 0], [0, 0, 0], [1, 0, 0]],
    [[1, 0, 0], [1, 1, 0], [0, 1, 0], [1, 0, 1], [1, 0, 0], [1, 0, 0]],
    [[1, 1, 0], [0, 1, 0], [1, 1, 0], [0, 1, 0], [0, 1, 0], [1, 0, 0]],
    [[0, 1, 1], [0, 1, 1], [1, 1, 1], [1, 0, 1], [1, 1, 0], [1, 0, 0]],
    [[0, 1, 0], [0, 0, 1], [1, 0, 1], [1, 1, 0], [0, 0, 1], [1, 0, 0]],
    [[1, 1, 1], [0, 0, 0], [1, 0, 0], [0, 0, 1], [1, 0, 1], [1, 0, 0]],
    [[1, 0, 1], [1, 0, 0], [0, 0, 0], [1, 1, 0], [0, 1, 1], [1, 0, 0]],
    [[0, 0, 0], [1, 0, 1], [0, 0, 1], [0, 0, 1], [1, 1, 1], [1, 0, 0]],
    [[0, 0, 0], [1, 1, 1], [1, 0, 1], [1, 0, 1], [0, 0, 0], [0, 1, 0]],
    [[1, 0, 1], [1, 1, 0], [1, 0, 0], [0, 1, 0], [1, 0, 0], [0, 1, 0]],
    [[1, 1, 1], [0, 1, 0], [0, 0, 0], [1, 0, 1], [0, 1, 0], [0, 1, 0]],
    [[0, 1, 0], [0, 1, 1], [0, 0, 1], [0, 1, 0], [1, 1, 0], [0, 1, 0]],
    [[0, 1, 1], [0, 0, 1], [0, 1, 1], [0, 0, 1], [0, 0, 1], [0, 1, 0]],
    [[1, 1, 0], [0, 0, 0], [0, 1, 0], [1, 1, 0], [1, 0, 1], [0, 1, 0]],
    [[1, 0, 0], [1, 0, 0], [1, 1, 0], [0, 0, 1], [0, 1, 1], [0, 1, 0]],
    [[0, 0, 1], [1, 0, 1], [1, 1, 1], [1, 1, 0], [1, 1, 1], [0, 1, 0]],
    [[0, 0, 1], [0, 0, 0], [1, 1, 0], [1, 1, 1], [0, 0, 0], [1, 1, 0]],
    [[1, 0, 0], [0, 0, 1], [1, 1, 1], [0, 0, 0], [1, 0, 0], [1, 1, 0]],
    [[1, 1, 0], [1, 0, 1], [0, 1, 1], [1, 1, 1], [0, 1, 0], [1, 1, 0]],
    [[0, 1, 1], [1, 0, 0], [0, 1, 0], [0, 0, 0], [1, 1, 0], [1, 1, 0]],
    [[0, 1, 0], [1, 1, 0], [0, 0, 0], [0, 1, 1], [0, 0, 1], [1, 1, 0]],
    [[1, 1, 1], [1, 1, 1], [0, 0, 1], [1, 0, 0], [1, 0, 1], [1, 1, 0]],
    [[1, 0, 1], [0, 1, 1], [1, 0, 1], [0, 1, 1], [0, 1, 1], [1, 1, 0]],
    [[0, 0, 0], [0, 1, 0], [1, 0, 0], [1, 0, 0], [1, 1, 1], [1, 1, 0]],
    [[1, 0, 1], [0, 1, 0], [1, 1, 1], [0, 0, 1], [0, 0, 0], [0, 0, 1]],
    [[0, 0, 0], [0, 1, 1], [1, 1, 0], [1, 1, 0], [1, 0, 0], [0, 0, 1]],
    [[0, 1, 0], [1, 1, 1], [0, 1, 0], [0, 0, 1], [0, 1, 0], [0, 0, 1]],
    [[1, 1, 1], [1, 1, 0], [0, 1, 1], [1, 1, 0], [1, 1, 0], [0, 0, 1]],
    [[1, 1, 0], [1, 0, 0], [0, 0, 1], [1, 0, 1], [0, 0, 1], [0, 0, 1]],
    [[0, 1, 1], [1, 0, 1], [0, 0, 0], [0, 1, 0], [1, 0, 1], [0, 0, 1]],
    [[0, 0, 1], [0, 0, 1], [1, 0, 0], [1, 0, 1], [0, 1, 1], [0, 0, 1]],
    [[1, 0, 0], [0, 0, 0], [1, 0, 1], [0, 1, 0], [1, 1, 1], [0, 0, 1]],
    [[1, 0, 0], [1, 0, 1], [1, 0, 0], [0, 1, 1], [0, 0, 0], [1, 0, 1]]
  ]

  @spec put_information(QR.t()) :: Result.t(String.t(), QR.t())
  def put_information(
        %QR{matrix: matrix, version: version, ecc_level: :low, mask_num: mask_num} = qr
      )
      when masking(mask_num) and version(version) and version < 7 do
    matrix
    |> Result.map(&set_format_info(&1, @low, mask_num, version))
    |> Result.map(fn matrix -> %{qr | matrix: matrix} end)
  end

  def put_information(
        %QR{matrix: matrix, version: version, ecc_level: :medium, mask_num: mask_num} = qr
      )
      when masking(mask_num) and version(version) and version < 7 do
    matrix
    |> Result.map(&set_format_info(&1, @medium, mask_num, version))
    |> Result.map(fn matrix -> %{qr | matrix: matrix} end)
  end

  def put_information(
        %QR{matrix: matrix, version: version, ecc_level: :quartile, mask_num: mask_num} = qr
      )
      when masking(mask_num) and version(version) and version < 7 do
    matrix
    |> Result.map(&set_format_info(&1, @quartile, mask_num, version))
    |> Result.map(fn matrix -> %{qr | matrix: matrix} end)
  end

  def put_information(
        %QR{matrix: matrix, version: version, ecc_level: :high, mask_num: mask_num} = qr
      )
      when masking(mask_num) and version(version) and version < 7 do
    matrix
    |> Result.map(&set_format_info(&1, @high, mask_num, version))
    |> Result.map(fn matrix -> %{qr | matrix: matrix} end)
  end

  def put_information(%QR{matrix: matrix, version: version} = qr) when version(version) do
    version_info =
      @version_table
      |> Enum.at(version - 7)

    matrix
    |> Matrix.update(version_info, {0, 4 * version + 6})
    |> Utils.put_to_list(Matrix.transpose(version_info))
    |> Result.and_then_x(&Matrix.update(&1, &2, {4 * version + 6, 0}))
    |> Result.map(fn matrix -> %{qr | matrix: matrix} end)
  end

  defp set_format_info(matrix, table_level, mask_num, version) do
    {row_1, row_2, col_1, col_2} = information_string(table_level, mask_num)

    matrix
    |> Result.and_then(&Matrix.update_row(&1, row_1, {8, 0}))
    |> Result.and_then(&Matrix.update_row(&1, row_2, {8, 4 * version + 9}))
    |> Result.and_then(&Matrix.update_col(&1, col_1, {4 * version + 9, 8}))
    |> Result.and_then(&Matrix.update_col(&1, col_2, {0, 8}))
  end

  defp information_string(table_level, mask_num) do
    {format_1, format_2} =
      table_level
      |> Enum.at(mask_num)
      |> Enum.split(7)

    format_1_added_1 =
      format_1
      |> List.pop_at(-1)
      |> (fn {last, list} -> Enum.concat(list, [1, last]) end).()

    format_2_added_1 =
      format_2
      |> Enum.split(2)
      |> (fn {first, rest} -> Enum.concat(first, [1 | rest]) end).()

    {format_1_added_1, format_2, Vector.transpose(format_1), Vector.transpose(format_2_added_1)}
  end
end
