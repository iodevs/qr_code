defmodule QRCode.Placement do
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
  alias QRCode.{QR, Utils}
  import QRCode.QR, only: [version: 1]

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

  @correct_finder [Matrix.new(7, 1), Matrix.new(5)]
                  |> Result.and_then_x(&Matrix.update(&1, &2, {1, 1}))
                  |> (fn mat -> [mat, Matrix.new(3, 1)] end).()
                  |> Result.and_then_x(&Matrix.update(&1, &2, {2, 2}))

  @correct_alignment [Matrix.new(5, 1), Matrix.new(3)]
                     |> Result.and_then_x(&Matrix.update(&1, &2, {1, 1}))
                     |> Result.and_then(&Matrix.update_element(&1, 1, {2, 2}))

  @correct_separator Vector.row(8)

  @spec put_patterns(QR.t()) :: Result.t(String.t(), QR.t())
  def put_patterns(%QR{version: version, encoded: encoding_data} = qr) when version(version) do
    size = (version - 1) * 4 + 21

    size
    |> Matrix.new()
    |> add_finders(version, @finder)
    |> add_separators(version, @separator)
    |> add_reserved_areas(version, @reserved_area)
    |> add_timings(version, @timing)
    |> add_alignments(version, @alignment)
    |> add_dark_module(version, @dark_module)
    |> Result.map(&fill_matrix_by_data(&1, size, encoding_data))
    |> Result.map(fn matrix -> %{qr | matrix: matrix} end)
  end

  def add_finders(matrix, version, finder \\ @correct_finder) do
    [matrix, finder]
    |> Result.and_then_x(&Matrix.update(&1, &2, {0, 0}))
    |> Utils.put_to_list(finder)
    |> Result.and_then_x(&Matrix.update(&1, &2, {0, 4 * version + 10}))
    |> Utils.put_to_list(finder)
    |> Result.and_then_x(&Matrix.update(&1, &2, {4 * version + 10, 0}))
  end

  def add_separators(matrix, version, row \\ @correct_separator) do
    col = Vector.transpose(row)

    matrix
    |> Result.and_then(&Matrix.update_row(&1, row, {7, 0}))
    |> Result.and_then(&Matrix.update_row(&1, row, {7, 4 * version + 9}))
    |> Result.and_then(&Matrix.update_row(&1, row, {4 * version + 9, 0}))
    |> Result.and_then(&Matrix.update_col(&1, col, {0, 7}))
    |> Result.and_then(&Matrix.update_col(&1, col, {0, 4 * version + 9}))
    |> Result.and_then(&Matrix.update_col(&1, col, {4 * version + 9, 7}))
  end

  def add_reserved_areas(matrix, version, val \\ 0)

  def add_reserved_areas(matrix, version, val) when version < 7 do
    row = Vector.row(8, val)
    col = Vector.transpose(row)

    matrix
    |> Result.and_then(&Matrix.update_row(&1, row, {8, 0}))
    |> Result.and_then(&Matrix.update_row(&1, row, {8, 4 * version + 9}))
    |> Result.and_then(&Matrix.update_col(&1, col, {4 * version + 9, 8}))
    |> Result.and_then(&Matrix.update_col(&1, Vector.col(9, val), {0, 8}))
  end

  def add_reserved_areas(matrix, version, val) do
    transp = val |> reserved_area() |> Result.map(&Matrix.transpose(&1))

    [matrix, reserved_area(val)]
    |> Result.and_then_x(&Matrix.update(&1, &2, {0, 4 * version + 6}))
    |> Utils.put_to_list(transp)
    |> Result.and_then_x(&Matrix.update(&1, &2, {4 * version + 6, 0}))
  end

  def add_timings(matrix, version, val \\ 0)

  def add_timings(matrix, version, 0) do
    size = 4 * version + 1

    row =
      size
      |> Vector.row()
      |> Vector.alternate_seq(1)

    matrix
    |> Result.and_then(&Matrix.update_row(&1, row, {6, 8}))
    |> Result.and_then(&Matrix.update_col(&1, Vector.transpose(row), {8, 6}))
  end

  def add_timings(matrix, version, val) when val != 0 do
    size = 4 * version + 1

    row =
      size
      |> Vector.row(val)

    matrix
    |> Result.and_then(&Matrix.update_row(&1, row, {6, 8}))
    |> Result.and_then(&Matrix.update_col(&1, Vector.transpose(row), {8, 6}))
  end

  def add_alignments(matrix, version, alignment \\ @correct_alignment)
  def add_alignments(matrix, 1, _alignment), do: matrix

  def add_alignments(matrix, version, alignment) when version < 6 do
    position = 4 * version + 8

    [matrix, alignment]
    |> Result.and_then_x(&Matrix.update(&1, &2, {position, position}))
  end

  def add_alignments(matrix, version, alignment) when version < 14 do
    positions = [2 * version + 8, 4 * version + 10]

    matrix
    |> add_alignments_to_horizontal_timing(alignment, positions)
    |> add_alignments_to_vertical_timing(alignment, positions)
    |> add_alignments_to_matrix(alignment, positions)
  end

  def add_alignments(matrix, version, alignment) do
    positions = find_positions(version)

    matrix
    |> add_alignments_to_horizontal_timing(alignment, positions)
    |> add_alignments_to_vertical_timing(alignment, positions)
    |> add_alignments_to_matrix(alignment, positions)
  end

  def add_dark_module(matrix, version, val \\ 1) do
    matrix
    |> Result.and_then(&Matrix.update_element(&1, val, {4 * version + 9, 8}))
  end

  def fill_matrix_by_data(matrix, size, encoding_data) do
    (size - 1)..7
    |> Enum.take_every(2)
    |> Enum.concat([5, 3, 1])
    |> Enum.map_reduce({matrix, encoding_data}, fn col, acc ->
      {col, make_fill(acc, [col, col - 1])}
    end)
    |> Kernel.elem(1)
    |> Kernel.elem(0)
  end

  defp make_fill({matrix, acc_data}, cols) do
    matrix
    |> Matrix.flip_ud()
    |> Enum.map_reduce(acc_data, fn row, acc_row ->
      fill_row(row, acc_row, cols)
    end)
  end

  defp fill_row(row, acc_row, cols) do
    row
    |> Enum.with_index()
    |> Enum.map_reduce(acc_row, fn {val, j}, acc_col ->
      if j in cols and val == 0 do
        <<cw::size(1), rest_bin::bitstring>> = acc_col
        {cw, rest_bin}
      else
        {val, acc_col}
      end
    end)
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
end
