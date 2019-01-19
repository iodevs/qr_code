defmodule QRCode.Pattern do
  @moduledoc """
  A patterns are a non-data element of the QR code that is required
  by the QR code specification, such as the three finder patterns in
  the corners of the QR code matrix.

  It contains function patterns (finder patterns, timing patterns,
  separators, alignment patterns) and reserved areas (format
  information area, version information area).

  0,1 ... Endcoding data
  2 ... Finders
  3 ... Separators
  4 ... Alignments
  5 ... Reserved areas
  6 ... Timing
  7 ... Dark module
  """

  alias MatrixReloaded.{Matrix, Vector}

  @locations [
    {14, [26, 46, 66]},
    {15, [26, 48, 70]},
    {16, [26, 50, 74]},
    {17, [30, 54, 78]},
    {18, [30, 56, 82]},
    {19, [30, 58, 86]},
    {20, [34, 62, 90]},
    {21, [28, 50, 72, 94]},
    {22, [26, 50, 74, 98]},
    {23, [30, 54, 78, 102]},
    {24, [28, 54, 80, 106]},
    {25, [32, 58, 84, 110]},
    {26, [30, 58, 86, 114]},
    {27, [34, 62, 90, 118]},
    {28, [26, 50, 74, 98, 122]},
    {29, [30, 54, 78, 102, 126]},
    {30, [26, 52, 78, 104, 130]},
    {31, [30, 56, 82, 108, 134]},
    {32, [34, 60, 86, 112, 138]},
    {33, [30, 58, 86, 114, 142]},
    {34, [34, 62, 90, 118, 146]},
    {35, [30, 54, 78, 102, 126, 150]},
    {36, [24, 50, 76, 102, 128, 154]},
    {37, [28, 54, 80, 106, 132, 158]},
    {38, [32, 58, 84, 110, 136, 162]},
    {39, [26, 54, 82, 110, 138, 166]},
    {40, [30, 58, 86, 114, 142, 170]}
  ]

  @finder Matrix.new(7, 2)
  @separator Vector.row(8, 3)
  @alignment Matrix.new(5, 4)
  @reserved_area 5
  @timing 6
  @dark_module 7

  def qr_matrix(version) do
    size = (version - 1) * 4 + 21

    size
    |> Matrix.new()
    |> add_finders(@finder, version)
    |> add_separators(@separator, version)
    |> add_reserved_areas(@reserved_area, version)
    |> add_timings(@timing, version)
    |> add_alignments(@alignment, version)
    |> add_dark_module(@dark_module, version)
  end

  def save_csv(version, file_name \\ "tmp/qr_code.csv") do
    file_name
    |> File.open([:write], fn file ->
      version
      |> qr_matrix()
      |> Result.and_then(&CSVLixir.write(&1))
      |> Enum.each(&IO.write(file, &1))
    end)
  end

  def add_finders(matrix, finder, version) do
    [matrix, finder]
    |> Result.and_then_x(&Matrix.update(&1, &2, {0, 0}))
    |> put_to_list(finder)
    |> Result.and_then_x(&Matrix.update(&1, &2, {0, 4 * version + 10}))
    |> put_to_list(finder)
    |> Result.and_then_x(&Matrix.update(&1, &2, {4 * version + 10, 0}))
  end

  def add_separators(matrix, row, version) do
    col = Vector.transpose(row)

    matrix
    |> Result.and_then(&Matrix.update_row(&1, row, {7, 0}))
    |> Result.and_then(&Matrix.update_row(&1, row, {7, 4 * version + 9}))
    |> Result.and_then(&Matrix.update_row(&1, row, {4 * version + 9, 0}))
    |> Result.and_then(&Matrix.update_col(&1, col, {0, 7}))
    |> Result.and_then(&Matrix.update_col(&1, col, {0, 4 * version + 9}))
    |> Result.and_then(&Matrix.update_col(&1, col, {4 * version + 9, 7}))
  end

  def add_reserved_areas(matrix, val, version) when version < 7 do
    row = Vector.row(8, val)
    col = Vector.transpose(row)

    matrix
    |> Result.and_then(&Matrix.update_row(&1, row, {8, 0}))
    |> Result.and_then(&Matrix.update_row(&1, row, {8, 4 * version + 9}))
    |> Result.and_then(&Matrix.update_col(&1, col, {4 * version + 9, 8}))
    |> Result.and_then(&Matrix.update_col(&1, Vector.col(9, val), {0, 8}))
  end

  def add_reserved_areas(matrix, val, version) do
    transp = reserved_area(val) |> Result.and_then(&Matrix.transpose(&1))

    [matrix, reserved_area(val)]
    |> Result.and_then_x(&Matrix.update(&1, &2, {0, 4 * version + 6}))
    |> put_to_list(transp)
    |> Result.and_then_x(&Matrix.update(&1, &2, {4 * version + 6, 0}))
  end

  def add_timings(matrix, val, version) do
    size = 4 * version + 1

    row =
      size
      |> Vector.row(val)

    # |> Vector.alternate_seq(1)

    matrix
    |> Result.and_then(&Matrix.update_row(&1, row, {6, 8}))
    |> Result.and_then(&Matrix.update_col(&1, Vector.transpose(row), {8, 6}))
  end

  def add_alignments(matrix, _sub, 1), do: matrix

  def add_alignments(matrix, alignment, version) when version < 6 do
    position = 4 * version + 8

    [matrix, alignment]
    |> Result.and_then_x(&Matrix.update(&1, &2, {position, position}))
  end

  def add_alignments(matrix, alignment, version) when version < 14 do
    positions = [2 * version + 8, 4 * version + 10]

    matrix
    |> add_alignments_to_horizontal_timing(alignment, positions)
    |> add_alignments_to_vertical_timing(alignment, positions)
    |> add_alignments_to_matrix(alignment, positions)
  end

  def add_alignments(matrix, alignment, version) do
    positions = find_positions(version)

    matrix
    |> add_alignments_to_horizontal_timing(alignment, positions)
    |> add_alignments_to_vertical_timing(alignment, positions)
    |> add_alignments_to_matrix(alignment, positions)
  end

  def add_dark_module(matrix, val, version) do
    matrix
    |> Result.and_then(&Matrix.update_element(&1, val, {4 * version + 9, 8}))
  end

  defp reserved_area(val) do
    Matrix.new({6, 3}, val)
  end

  defp add_alignments_to_horizontal_timing(matrix, alignment, positions) do
    positions
    |> Enum.drop(-1)
    |> generate_positions(6)
    |> Enum.reduce(matrix, fn {row_pos, col_pos}, acc ->
      Result.and_then_x(
        [acc, alignment],
        &Matrix.update(&1, &2, {row_pos - 2, col_pos - 2})
      )
    end)
  end

  defp add_alignments_to_vertical_timing(matrix, alignment, positions) do
    positions
    |> Enum.drop(-1)
    |> generate_positions(6)
    |> Enum.reduce(matrix, fn {row_pos, col_pos}, acc ->
      Result.and_then_x(
        [acc, alignment],
        &Matrix.update(&1, &2, {col_pos - 2, row_pos - 2})
      )
    end)
  end

  defp add_alignments_to_matrix(matrix, alignment, positions) do
    positions
    |> generate_positions()
    |> Enum.reduce(matrix, fn {row_pos, col_pos}, acc ->
      Result.and_then_x(
        [acc, alignment],
        &Matrix.update(&1, &2, {row_pos - 2, col_pos - 2})
      )
    end)
  end

  defp find_positions(version) do
    Enum.reduce_while(@locations, version, fn {ver, list_center}, acc ->
      if version == ver do
        {:halt, list_center}
      else
        {:cont, acc}
      end
    end)
  end

  defp generate_positions(list) do
    for x <- list, y <- list, do: {x, y}
  end

  defp generate_positions(list, num) do
    for x <- [num], y <- list, do: {x, y}
  end

  defp put_to_list(el, tpl) do
    el
    |> List.wrap()
    |> Kernel.++([tpl])
  end
end
