defmodule QRCode.Masking do
  @moduledoc """
  A mask pattern changes which modules are dark and which are light
  according to a particular rule. The purpose of this step is to
  modify the QR code to make it as easy for a QR code reader to scan
  as possible.
  """
  use Bitwise

  alias MatrixReloaded.{Matrix}
  alias QRCode.Pattern

  @spec make(Result.t(String.t(), Matrix.t()), pos_integer, non_neg_integer) ::
          Result.t(String.t(), Matrix.t())
  def make(matrix, version, mask_num) do
    matrix
    |> Result.map(&make_mask_pattern(&1, mask_num))
    |> Pattern.add_finders(version)
    |> Pattern.add_separators(version)
    |> Pattern.add_reserved_areas(version)
    |> Pattern.add_timings(version)
    |> Pattern.add_alignments(version)
    |> Pattern.add_dark_module(version)
  end

  defp make_mask_pattern(matrix, mask_num) do
    matrix
    |> Enum.with_index()
    |> Enum.map(fn {row, i} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {_col, j} ->
        row |> Enum.at(j) |> mask_pattern(i, j, mask_num)
      end)
    end)
  end

  def penalty_1(matrix) do
    row_pen_1 =
      matrix
      |> Enum.reduce(0, fn [h | _] = row, acc ->
        row
        |> Enum.reduce({h, 0, acc}, &compute_penalty_1/2)
        |> (fn {__selected, _sum, val} -> val end).()
      end)

    col_pen_1 =
      matrix
      |> Matrix.transpose()
      |> Enum.reduce(0, fn [h | _] = row, acc ->
        row
        |> Enum.reduce({h, 0, acc}, &compute_penalty_1/2)
        |> (fn {__selected, _sum, val} -> val end).()
      end)

    row_pen_1 + col_pen_1
  end

  defp compute_penalty_1(val, {selected, sum, acc}) when val == selected and sum < 4 do
    {val, sum + 1, acc}
  end

  defp compute_penalty_1(val, {selected, 4, acc}) when val == selected do
    {val, 5, acc + 3}
  end

  defp compute_penalty_1(val, {selected, sum, acc}) when val == selected and sum > 4 do
    {val, sum + 1, acc + 1}
  end

  defp compute_penalty_1(val, {_val, _sum, acc}) do
    {val, 1, acc}
  end

  defp mask_pattern(val, row, col, 0) when rem(row + col, 2) == 0, do: val ^^^ 1
  defp mask_pattern(val, row, _col, 1) when rem(row, 2) == 0, do: val ^^^ 1
  defp mask_pattern(val, _row, col, 2) when rem(col, 3) == 0, do: val ^^^ 1
  defp mask_pattern(val, row, col, 3) when rem(row + col, 3) == 0, do: val ^^^ 1

  defp mask_pattern(val, row, col, 4)
       when rem(floor(row / 2) + floor(col / 3), 2) == 0,
       do: val ^^^ 1

  defp mask_pattern(val, row, col, 5)
       when rem(row * col, 2) + rem(row * col, 3) == 0,
       do: val ^^^ 1

  defp mask_pattern(val, row, col, 6)
       when rem(rem(row * col, 2) + rem(row * col, 3), 2) == 0,
       do: val ^^^ 1

  defp mask_pattern(val, row, col, 7)
       when rem(rem(row + col, 2) + rem(row * col, 3), 2) == 0,
       do: val ^^^ 1

  defp mask_pattern(val, _row, _col, _mask_num), do: val
end
