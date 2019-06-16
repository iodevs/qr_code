defmodule QRCode.Polynom do
  @moduledoc """
  An polynom math library
  """

  alias QRCode.GaloisField, as: GF
  alias QRCode.GeneratorPolynomial, as: GP

  use Bitwise

  @spec div([GF.value()], GP.polynomial()) :: [GF.value()]
  def div(dividend, divisor) do
    dividend
    |> Stream.iterate(&do_div(&1, divisor))
    |> Enum.at(Enum.count(dividend))
    |> fill_to_degree(Enum.count(divisor) - 1)
  end

  defp do_div([0 | t], _), do: t

  defp do_div([first | _] = dividend, divisor) do
    divisor
    |> Enum.map(fn val -> val |> GF.add(GF.to_a(first)) |> GF.to_i() end)
    |> zip(dividend)
    |> Enum.map(fn {a, b} -> a ^^^ b end)
    |> tl()
  end

  defp zip(left, right) do
    [short, long] = Enum.sort_by([left, right], &length/1)

    short
    |> Stream.concat(Stream.cycle([0]))
    |> Stream.zip(long)
  end

  defp fill_to_degree(list, degree) when length(list) < degree do
    list ++ List.duplicate(0, degree - Enum.count(list))
  end

  defp fill_to_degree(result, _) do
    result
  end
end
