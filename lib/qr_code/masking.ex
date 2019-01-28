defmodule QRCode.Masking do
  @moduledoc """
  A mask pattern changes which modules are dark and which are light
  according to a particular rule. The purpose of this step is to
  modify the QR code to make it as easy for a QR code reader to scan
  as possible.
  """
  use Bitwise

  alias MatrixReloaded.Matrix
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
    row_pen =
      matrix
      |> compute_penalty_1()

    col_pen =
      matrix
      |> Matrix.transpose()
      |> compute_penalty_1()

    row_pen + col_pen
  end

  def penalty_2(matrix) do
    matrix
    |> compute_penalty_2()
  end

  def penalty_3(matrix) do
    row_pen =
      matrix
      |> compute_penalty_3()

    col_pen =
      matrix
      |> Matrix.transpose()
      |> compute_penalty_3()

    row_pen + col_pen
  end

  def penalty_4(matrix) do
    {rs, cs} = Matrix.size(matrix)

    dark_modules =
      matrix
      |> Enum.reduce(0, fn row, acc -> Enum.sum(row) + acc end)

    percent_of_dark =
      (dark_modules * 100 / (rs * cs))
      |> Kernel.floor()

    reminder =
      percent_of_dark
      |> Kernel.rem(5)

    Kernel.min(
      Kernel.abs(percent_of_dark - reminder - 50) / 5,
      Kernel.abs(percent_of_dark - reminder - 45) / 5
    ) * 10
  end

  defp compute_penalty_1(matrix) do
    matrix
    |> Enum.reduce(0, fn [h | _] = row, acc ->
      row
      |> Enum.reduce({h, 0, acc}, &evaluate_cond_1/2)
      |> (fn {__selected, _sum, val} -> val end).()
    end)
  end

  defp evaluate_cond_1(val, {selected, sum, acc}) when val == selected and sum < 4 do
    {val, sum + 1, acc}
  end

  defp evaluate_cond_1(val, {selected, 4, acc}) when val == selected do
    {val, 5, acc + 3}
  end

  defp evaluate_cond_1(val, {selected, sum, acc}) when val == selected and sum > 4 do
    {val, sum + 1, acc + 1}
  end

  defp evaluate_cond_1(val, {_val, _sum, acc}) do
    {val, 1, acc}
  end

  defp compute_penalty_2(rows, acc \\ 0)

  defp compute_penalty_2(rows, acc) when length(rows) == 1 do
    acc
  end

  defp compute_penalty_2([row1, row2 | rows], acc) do
    acc_row =
      row1
      |> map2(row2, fn v1, v2 -> v1 + v2 end)
      |> evaluate_cond_2()

    compute_penalty_2([row2] ++ rows, acc + acc_row)
  end

  defp evaluate_cond_2(row, sum \\ 0)

  defp evaluate_cond_2(row, sum) when length(row) == 1 do
    sum
  end

  defp evaluate_cond_2([v1, v2 | tl], sum) when v1 + v2 == 0 or v1 + v2 == 4 do
    evaluate_cond_2([v2] ++ tl, sum + 3)
  end

  defp evaluate_cond_2([_v1 | tl], sum) do
    evaluate_cond_2(tl, sum)
  end

  defp compute_penalty_3(matrix) do
    matrix
    |> Enum.reduce(0, fn row, acc -> evaluate_cond_3(row, acc) end)
  end

  defp evaluate_cond_3(row, sum) when length(row) < 11 do
    sum
  end

  defp evaluate_cond_3([a, b, c, d, e, f, g, h, i, j, k | tl], sum) do
    check = [a, b, c, d, e, f, g, h, i, j, k]
    patt_1 = [1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0]
    patt_2 = [0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1]

    pen =
      if check == patt_1 or check == patt_2 do
        40
      else
        0
      end

    evaluate_cond_3([b, c, d, e, f, g, h, i, j, k] ++ tl, sum + pen)
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

  defp map2([h1 | t1], [h2 | t2], fun) do
    [fun.(h1, h2) | map2(t1, t2, fun)]
  end

  defp map2([], [], _fun) do
    []
  end
end
