defmodule QRCode.Pattern do
  @moduledoc """
  A patterns are a non-data element of the QR code that is required
  by the QR code specification, such as the three finder patterns in
  the corners of the QR code matrix.
  """

  alias QRCode.{Matrix, Vector}

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
    Matrix.new((version - 1) * 4 + 21)
    |> add_finders(version)
    |> add_alignments(version)
    |> add_timings(version)
    |> add_dark_module(version)
  end

  def save_csv(version) do
    {_, mat} = qr_matrix(version)

    f = File.open!("tmp/qr_code.csv", [:write])

    mat
    |> CSVLixir.write()
    |> Enum.each(&IO.write(f, &1))

    File.close(f)
  end

  defp add_finders(matrix, version) do
    matrix
    |> and_then2(finder(), &Matrix.update(&1, {0, 0}, {6, 6}, &2))
    |> and_then2(
      finder(),
      &Matrix.update(&1, {0, 4 * version + 10}, {6, 4 * version + 16}, &2)
    )
    |> and_then2(
      finder(),
      &Matrix.update(&1, {4 * version + 10, 0}, {4 * version + 16, 6}, &2)
    )
  end

  defp add_timings(matrix, version) do
    row =
      Vector.row(4 * version + 1)
      |> Vector.alternate_seq(1)

    end_position = {8, 4 * version + 8}

    matrix
    |> Result.and_then(&Matrix.update_row(&1, 6, end_position, row))
    |> Result.and_then(&Matrix.update_col(&1, 6, end_position, Vector.transpose(row)))
  end

  defp add_alignments(matrix, 1), do: matrix

  defp add_alignments(matrix, version) when version < 6 do
    position = 4 * version + 8

    matrix
    |> and_then2(
      alignment(),
      &Matrix.update(&1, {position, position}, {position + 4, position + 4}, &2)
    )
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
    Matrix.new(7, 1)
    |> and_then2(Matrix.new(5), &Matrix.update(&1, {1, 1}, {5, 5}, &2))
    |> and_then2(Matrix.new(3, 1), &Matrix.update(&1, {2, 2}, {4, 4}, &2))
  end

  defp alignment() do
    Matrix.new(5, 1)
    |> and_then2(Matrix.new(3), &Matrix.update(&1, {1, 1}, {3, 3}, &2))
    |> Result.and_then(&Matrix.update_element(&1, 2, 2, 1))
  end

  defp add_dark_module(matrix, version) do
    matrix
    |> Result.and_then(&Matrix.update_element(&1, 4 * version + 9, 8, 1))
  end

  defp and_then2({:ok, val1}, {:ok, val2}, f) when is_function(f, 2) do
    f.(val1, val2)
  end

  defp and_then2({:error, _} = result, _, _f), do: result
  defp and_then2(_, {:error, _} = result, _f), do: result

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
      and_then2(
        acc,
        alignment(),
        &Matrix.update(&1, {row_pos - 2, col_pos - 2}, {row_pos + 2, col_pos + 2}, &2)
      )
    end)
  end

  defp add_aligments_to_vertical_timing(matrix, positions) do
    positions
    |> Enum.drop(-1)
    |> generate_positions(6)
    |> Enum.reduce(matrix, fn {row_pos, col_pos}, acc ->
      and_then2(
        acc,
        alignment(),
        &Matrix.update(&1, {col_pos - 2, row_pos - 2}, {col_pos + 2, row_pos + 2}, &2)
      )
    end)
  end

  defp add_aligments_to_matrix(matrix, positions) do
    positions
    |> generate_positions()
    |> Enum.reduce(matrix, fn {row_pos, col_pos}, acc ->
      and_then2(
        acc,
        alignment(),
        &Matrix.update(&1, {row_pos - 2, col_pos - 2}, {row_pos + 2, col_pos + 2}, &2)
      )
    end)
  end
end
