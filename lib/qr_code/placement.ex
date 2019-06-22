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
  alias QRCode.QR
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

  @finder Matrix.new(7, 2) |> elem(1)
  @separator Vector.row(8, 3)
  @alignment Matrix.new(5, 4) |> elem(1)
  @reserved_area 5
  @timing 6
  @dark_module 7

  @correct_finder [Matrix.new(7, 1), Matrix.new(5)]
                  |> Result.and_then_x(&Matrix.update(&1, &2, {1, 1}))
                  |> (fn mat -> [mat, Matrix.new(3, 1)] end).()
                  |> Result.and_then_x(&Matrix.update(&1, &2, {2, 2}))
                  |> elem(1)

  @correct_alignment [Matrix.new(5, 1), Matrix.new(3)]
                     |> Result.and_then_x(&Matrix.update(&1, &2, {1, 1}))
                     |> Result.and_then(&Matrix.update_element(&1, 1, {2, 2}))
                     |> elem(1)

  @correct_separator Vector.row(8)

  @spec put_patterns(QR.t()) :: Result.t(String.t(), QR.t())
  def put_patterns(%QR{version: version, message: message} = qr) when version(version) do
    size = (version - 1) * 4 + 21

    size
    |> Matrix.new()
    |> Result.and_then(&add_finders(&1, version, @finder))
    |> Result.and_then(&add_separators(&1, version, @separator))
    |> Result.and_then(&add_reserved_areas(&1, version, @reserved_area))
    |> Result.and_then(&add_timings(&1, version, @timing))
    |> Result.and_then(&add_alignments(&1, version, @alignment))
    |> Result.and_then(&add_dark_module(&1, version, @dark_module))
    |> Result.map(&fill_matrix_by_message(&1, size, message))
    |> Result.map(fn matrix -> %{qr | matrix: matrix} end)
  end

  @spec replace_placeholders(QR.t()) :: Result.t(String.t(), QR.t())
  def replace_placeholders(%QR{matrix: matrix, version: version} = qr) when version(version) do
    matrix
    |> add_finders(version)
    |> Result.and_then(&add_separators(&1, version))
    |> Result.and_then(&add_reserved_areas(&1, version))
    |> Result.and_then(&add_timings(&1, version))
    |> Result.and_then(&add_alignments(&1, version))
    |> Result.and_then(&add_dark_module(&1, version))
    |> Result.map(fn matrix -> %{qr | matrix: matrix} end)
  end

  @spec add_finders(Matrix.t(), QR.version(), Matrix.t()) :: Result.t(String.t(), Matrix.t())
  def add_finders(matrix, version, finder \\ @correct_finder) do
    matrix
    |> Matrix.update(finder, {0, 0})
    |> Result.and_then(&Matrix.update(&1, finder, {0, 4 * version + 10}))
    |> Result.and_then(&Matrix.update(&1, finder, {4 * version + 10, 0}))
  end

  @spec add_separators(Matrix.t(), QR.version(), Vector.t()) :: Result.t(String.t(), Matrix.t())
  def add_separators(matrix, version, row \\ @correct_separator) do
    col = Vector.transpose(row)

    matrix
    |> Matrix.update_row(row, {7, 0})
    |> Result.and_then(&Matrix.update_row(&1, row, {7, 4 * version + 9}))
    |> Result.and_then(&Matrix.update_row(&1, row, {4 * version + 9, 0}))
    |> Result.and_then(&Matrix.update_col(&1, col, {0, 7}))
    |> Result.and_then(&Matrix.update_col(&1, col, {0, 4 * version + 9}))
    |> Result.and_then(&Matrix.update_col(&1, col, {4 * version + 9, 7}))
  end

  @spec add_reserved_areas(Matrix.t(), QR.version(), non_neg_integer()) ::
          Result.t(String.t(), Matrix.t())
  def add_reserved_areas(matrix, version, val \\ 0)

  def add_reserved_areas(matrix, version, val) when version < 7 do
    add_reserve_fia(matrix, version, val)
  end

  def add_reserved_areas(matrix, version, val) do
    matrix
    |> add_reserve_fia(version, val)
    |> add_reserve_via(version, val)
  end

  @spec add_timings(Matrix.t(), QR.version()) :: Result.t(String.t(), Matrix.t())
  def add_timings(matrix, version) do
    row = get_timing_row(version)

    [row |> Result.and_then(&Matrix.update_row(matrix, &1, {6, 8})), row]
    |> Result.and_then_x(&Matrix.update_col(&1, Vector.transpose(&2), {8, 6}))
  end

  @spec add_timings(Matrix.t(), QR.version(), pos_integer()) :: Result.t(String.t(), Matrix.t())
  def add_timings(matrix, version, val) do
    size = 4 * version + 1
    row = size |> Vector.row(val)

    matrix
    |> Matrix.update_row(row, {6, 8})
    |> Result.and_then(&Matrix.update_col(&1, Vector.transpose(row), {8, 6}))
  end

  @spec add_alignments(Matrix.t(), QR.version(), Matrix.t()) :: Result.t(String.t(), Matrix.t())
  def add_alignments(matrix, version, alignment \\ @correct_alignment)
  def add_alignments(matrix, 1, _alignment), do: Result.ok(matrix)

  def add_alignments(matrix, version, alignment) when version < 7 do
    Matrix.update(matrix, alignment, {4 * version + 8, 4 * version + 8})
  end

  def add_alignments(matrix, version, alignment) when version < 14 do
    Matrix.update_map(matrix, alignment, get_all_positions([2 * version + 8, 4 * version + 10]))
  end

  def add_alignments(matrix, version, alignment) do
    positions =
      version
      |> find_positions()
      |> get_all_positions()

    Matrix.update_map(matrix, alignment, positions)
  end

  @spec add_dark_module(Matrix.t(), QR.version(), pos_integer()) ::
          Result.t(String.t(), Matrix.t())
  def add_dark_module(matrix, version, val \\ 1) do
    Matrix.update_element(matrix, val, {4 * version + 9, 8})
  end

  defp fill_matrix_by_message(matrix, size, message) do
    (size - 1)..7
    |> Enum.take_every(2)
    |> Enum.concat([5, 3, 1])
    |> Enum.map_reduce({matrix, message}, fn col, acc ->
      {col, make_fill(acc, [col, col - 1])}
    end)
    |> Kernel.elem(1)
    |> Kernel.elem(0)
  end

  defp make_fill({matrix, acc_message}, cols) do
    matrix
    |> Matrix.flip_ud()
    |> Enum.map_reduce(acc_message, fn row, acc_msg ->
      fill_row(row, acc_msg, cols)
    end)
  end

  defp fill_row(row, acc_msg, cols) do
    Enum.reduce(cols, {row, acc_msg}, fn col, {row, msg} ->
      if Enum.at(row, col) == 0 do
        <<cw::size(1), rest::bitstring>> = msg

        {List.update_at(row, col, fn _ -> cw end), rest}
      else
        {row, msg}
      end
    end)
  end

  defp reserved_area(val) do
    {6, 3} |> Matrix.new(val) |> elem(1)
  end

  defp add_reserve_fia(matrix, version, val) do
    row_left = Vector.row(6, val) ++ [0] ++ [val, val]
    row_right = Vector.row(8, val)
    col_top = Vector.transpose(row_left)
    col_bottom = Vector.col(7, val)

    matrix
    |> Matrix.update_row(row_left, {8, 0})
    |> Result.and_then(&Matrix.update_row(&1, row_right, {8, 4 * version + 9}))
    |> Result.and_then(&Matrix.update_col(&1, col_top, {0, 8}))
    |> Result.and_then(&Matrix.update_col(&1, col_bottom, {4 * version + 10, 8}))
  end

  defp add_reserve_via(matrix, version, val) do
    transp = val |> reserved_area() |> Matrix.transpose()

    matrix
    |> Result.and_then(&Matrix.update(&1, reserved_area(val), {0, 4 * version + 6}))
    |> Result.and_then(&Matrix.update(&1, transp, {4 * version + 6, 0}))
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

  defp generate_positions(list, :horizontal) do
    for x <- [6], y <- Enum.drop(list, -1), do: {x, y}
  end

  defp generate_positions(list, :vertical) do
    for x <- Enum.drop(list, -1), y <- [6], do: {x, y}
  end

  defp get_positions(version) when version < 14 do
    [2 * version + 8, 4 * version + 10]
  end

  defp get_positions(version) do
    find_positions(version)
  end

  defp get_all_positions(list) do
    list
    |> generate_positions()
    |> Kernel.++(generate_positions(list, :horizontal))
    |> Kernel.++(generate_positions(list, :vertical))
    |> Enum.map(fn {row_pos, col_pos} -> {row_pos - 2, col_pos - 2} end)
  end

  defp get_timing_row(version) when version < 7 do
    size = 4 * version + 1

    size
    |> Vector.row()
    |> Vector.alternate_seq(1)
    |> Result.ok()
  end

  defp get_timing_row(version) do
    size = 4 * version + 1

    positions =
      version
      |> get_positions()
      |> generate_positions(:horizontal)
      |> Enum.map(fn {_row_pos, col_pos} -> col_pos - 10 end)

    size
    |> Vector.row()
    |> Vector.alternate_seq(1)
    |> Vector.update_map(
      [0, 0, 0, 0, 0],
      positions
    )
  end
end
