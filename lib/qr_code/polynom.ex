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

    [0 | result] = xor(dividend, multipled_divisor)
    div(result, divisor, step - 1)
  end

  defp xor(dividend, divisor, acc \\ [])
  defp xor([], [], acc), do: Enum.reverse(acc)
  defp xor([], [b | divisor], acc), do: xor([], divisor, [b | acc])
  defp xor([a | dividend], [b | divisor], acc), do: xor(dividend, divisor, [a ^^^ b | acc])
end
