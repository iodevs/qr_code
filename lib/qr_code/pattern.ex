defmodule QRCode.Pattern do
  @moduledoc """
  A patterns are a non-data element of the QR code that is required
  by the QR code specification, such as the three finder patterns in
  the corners of the QR code matrix.


  1 ... Finders
  2 ... Separators
  3 ... Alignments
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

  def qr_matrix(version) do
    size = (version - 1) * 4 + 21

    size
    |> Matrix.new()
    |> add_finders(version)
    |> add_separators(version)
    |> add_alignments(version)
    |> add_timings(version)
    |> add_dark_module(version)
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

  defp add_finders(matrix, version) do
    [matrix, finder()]
    |> Result.and_then_x(&Matrix.update(&1, &2, {0, 0}))
    |> put_to_list(finder())
    |> Result.and_then_x(&Matrix.update(&1, &2, {0, 4 * version + 10}))
    |> put_to_list(finder())
    |> Result.and_then_x(&Matrix.update(&1, &2, {4 * version + 10, 0}))
  end

  defp add_separators(matrix, version) do
    row = Vector.row(8, 2)
    col = Vector.transpose(row)

    matrix
    |> Result.and_then(&Matrix.update_row(&1, row, {7, 0}))
    |> Result.and_then(&Matrix.update_row(&1, row, {7, 4 * version + 9}))
    |> Result.and_then(&Matrix.update_row(&1, row, {4 * version + 9, 0}))
    |> Result.and_then(&Matrix.update_col(&1, col, {0, 7}))
    |> Result.and_then(&Matrix.update_col(&1, col, {0, 4 * version + 9}))
    |> Result.and_then(&Matrix.update_col(&1, col, {4 * version + 9, 7}))
  end

  defp add_timings(matrix, version) do
    size = 4 * version + 1

    row =
      size
      |> Vector.row()
      |> Vector.alternate_seq(1)

    matrix
    |> Result.and_then(&Matrix.update_row(&1, row, {6, 8}))
    |> Result.and_then(&Matrix.update_col(&1, Vector.transpose(row), {8, 6}))
  end

  defp add_alignments(matrix, 1), do: matrix

  defp add_alignments(matrix, version) when version < 6 do
    position = 4 * version + 8

    [matrix, alignment()]
    |> Result.and_then_x(&Matrix.update(&1, &2, {position, position}))
  end

  defp add_alignments(matrix, version) when version < 14 do
    positions = [2 * version + 8, 4 * version + 10]

    matrix
    |> add_aligments_to_horizontal_timing(positions)
    |> add_aligments_to_vertical_timing(positions)
    |> add_aligments_to_matrix(positions)
  end

  defp add_alignments(matrix, version) do
    positions = find_positions(version)

    matrix
    |> add_aligments_to_horizontal_timing(positions)
    |> add_aligments_to_vertical_timing(positions)
    |> add_aligments_to_matrix(positions)
  end

  defp finder() do
    [Matrix.new(7, 1), Matrix.new(5)]
    |> Result.and_then_x(&Matrix.update(&1, &2, {1, 1}))
    |> put_to_list(Matrix.new(3, 1))
    |> Result.and_then_x(&Matrix.update(&1, &2, {2, 2}))
  end

  defp alignment() do
    [Matrix.new(5, 3), Matrix.new(3)]
    |> Result.and_then_x(&Matrix.update(&1, &2, {1, 1}))
    |> Result.and_then(&Matrix.update_element(&1, 3, {2, 2}))
  end

  defp add_dark_module(matrix, version) do
    matrix
    |> Result.and_then(&Matrix.update_element(&1, 1, {4 * version + 9, 8}))
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

  defp add_aligments_to_horizontal_timing(matrix, positions) do
    positions
    |> Enum.drop(-1)
    |> generate_positions(6)
    |> Enum.reduce(matrix, fn {row_pos, col_pos}, acc ->
      Result.and_then_x(
        [acc, alignment()],
        &Matrix.update(&1, &2, {row_pos - 2, col_pos - 2})
      )
    end)
  end

  defp add_aligments_to_vertical_timing(matrix, positions) do
    positions
    |> Enum.drop(-1)
    |> generate_positions(6)
    |> Enum.reduce(matrix, fn {row_pos, col_pos}, acc ->
      Result.and_then_x(
        [acc, alignment()],
        &Matrix.update(&1, &2, {col_pos - 2, row_pos - 2})
      )
    end)
  end

  defp add_aligments_to_matrix(matrix, positions) do
    positions
    |> generate_positions()
    |> Enum.reduce(matrix, fn {row_pos, col_pos}, acc ->
      Result.and_then_x(
        [acc, alignment()],
        &Matrix.update(&1, &2, {row_pos - 2, col_pos - 2})
      )
    end)
  end

  defp put_to_list(el, list) do
    [el, list]
  end
end
