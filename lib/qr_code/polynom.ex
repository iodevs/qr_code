defmodule QRCode.Polynom do
  @moduledoc """
  An polynom math library
  """

  alias QRCode.GaloisField, as: GF
  alias QRCode.GeneratorPolynomial, as: GP

  use Bitwise

  @spec div([GF.value()], GP.polynomial()) :: [GF.value()]
  def div(dividend, divisor) do
    div(dividend, divisor, Enum.count(dividend))
  end

  defp div(dividend, _, 0), do: dividend

  defp div([first | _] = dividend, divisor, step) do
    multipled_divisor =
      Enum.map(divisor, fn val -> val |> GF.add(GF.to_a(first)) |> GF.to_i() end)

    {result, step} =
      dividend
      |> xor(multipled_divisor)
      |> trim_leading_zero(step)
      |> fill_to_degree(Enum.count(divisor) - 1)

    div(result, divisor, step)
  end

  defp xor(dividend, divisor, acc \\ [])
  defp xor([], [], acc), do: Enum.reverse(acc)
  defp xor([], [b | divisor], acc), do: xor([], divisor, [b | acc])
  defp xor([a | dividend], [b | divisor], acc), do: xor(dividend, divisor, [a ^^^ b | acc])

  defp trim_leading_zero([0 | list], step) do
    trim_leading_zero(list, step - 1)
  end

  defp trim_leading_zero(list, step) do
    {list, step}
  end

  defp fill_to_degree({list, step}, degree) when length(list) < degree do
    {list ++ List.duplicate(0, degree - Enum.count(list)), step}
  end

  defp fill_to_degree(result, _) do
    result
  end
end
