defmodule QRCode.Masking do
  @moduledoc """
  A mask pattern changes which modules are dark and which are light
  according to a particular rule. The purpose of this step is to
  modify the QR code to make it as easy for a QR code reader to scan
  as possible.
  """
  use Bitwise

  alias MatrixReloaded.{Matrix, Vector}
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

  def make_mask_pattern(matrix, mask_num) do
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
