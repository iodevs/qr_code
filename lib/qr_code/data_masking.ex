defmodule QRCode.DataMasking do
  @moduledoc """
  A mask pattern changes which modules are dark and which are light
  according to a particular rule. The purpose of this step is to
  modify the QR code to make it as easy for a QR code reader to scan
  as possible.
  """
  use Bitwise

  alias MatrixReloaded.Matrix
  alias QRCode.QR
  import QRCode.QR, only: [version: 1]

  @spec apply(QR.t()) :: QR.t()
  def apply(%QR{matrix: matrix, version: version} = qr)
      when version(version) do
    {index, masked_matrix} =
      matrix
      |> masking_matrices()
      |> total_penalties()
      |> best_mask()

    %{qr | matrix: masked_matrix, mask_num: index}
  end

  @spec masking_matrices(Matrix.t()) :: Enumerable.t()
  def masking_matrices(matrix) do
    Stream.map(0..7, fn num -> {num, make_mask_pattern(matrix, num)} end)
  end

  @spec total_penalties(Enumerable.t()) :: Enumerable.t()
  def total_penalties(matrices) do
    Stream.map(matrices, fn {num, matrix} -> {num, total_penalty(matrix), matrix} end)
  end

  @spec best_mask(Enumerable.t()) :: {non_neg_integer(), Matrix.t()}
  def best_mask(matrices) do
    [{index, _, masked_matrix} | _] =
      matrices
      |> Enum.sort(fn {_, p1, _}, {_, p2, _} -> p1 <= p2 end)

    {index, masked_matrix}
  end

  @spec total_penalty(Matrix.t()) :: pos_integer()
  def total_penalty(matrix) do
    Enum.reduce(1..4, 0, fn pen, sum -> penalty(matrix, pen) + sum end)
  end

  @spec penalty(Matrix.t(), 1 | 2 | 3 | 4) :: non_neg_integer()
  def penalty(matrix, 1) do
    row_pen =
      matrix
      |> compute_penalty_1()

    col_pen =
      matrix
      |> Matrix.transpose()
      |> compute_penalty_1()

    row_pen + col_pen
  end

  def penalty(matrix, 2) do
    matrix
    |> compute_penalty_2()
  end

  def penalty(matrix, 3) do
    row_pen =
      matrix
      |> compute_penalty_3()

    col_pen =
      matrix
      |> Matrix.transpose()
      |> compute_penalty_3()

    row_pen + col_pen
  end

  def penalty(matrix, 4) do
    {rs, cs} = Matrix.size(matrix)

    dark_modules =
      matrix
      |> Enum.reduce(0, fn row, acc -> Enum.sum(row) + acc end)

    percent_of_dark = Kernel.floor(dark_modules * 100 / (rs * cs))

    reminder =
      percent_of_dark
      |> Kernel.rem(5)

    Kernel.trunc(
      Kernel.min(
        Kernel.abs(percent_of_dark - reminder - 50) / 5,
        Kernel.abs(percent_of_dark - reminder - 45) / 5
      ) * 10
    )
  end

  defp make_mask_pattern(matrix, mask_num) do
    matrix
    |> Enum.with_index()
    |> Enum.map(fn {row, i} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {val, j} -> mask_pattern(val, i, j, mask_num) end)
    end)
  end

  defp compute_penalty_1(matrix) do
    matrix
    |> Enum.reduce(0, fn [h | _] = row, acc ->
      row
      |> Enum.reduce({h, 0, acc}, &evaluate_cond_1/2)
      |> Kernel.elem(2)
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
      |> Enum.zip(row2)
      |> Enum.map(fn {v1, v2} -> v1 + v2 end)
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
end
