defmodule QRCode.GeneratorPolynomial do
  @moduledoc """
  Error correction coding uses polynomial long division.  To do that,
  two polynomials are needed. The first polynomial to use is called the message
  polynomial. The message polynomial uses the data codewords
  from the data encoding step as its coefficients. For example,
  if the data codewords, converted to integers, were *25, 218, and 35,*
  the message polynomial would be *25x2 + 218x + 35.* In practice,
  real message polynomials for standard QR codes are much longer,
  but this is just an example.

  The message polynomial will be divided by a generator polynomial.
  The generator polynomial is a polynomial that is created by multiplying
  `(x - a0) ... (x - a(n-1))`
  where `n` is the number of error correction codewords
  that must be generated (see the error correction table).
  """

  alias QRCode.GaloisField, as: GField

  use Bitwise

  @type degree() :: 1..254
  @type polynomial() :: [GField.alpha()]

  @doc """
  Returns generator polynomials in alpha exponent for given error code length.
  Example:
      iex> QRCode.GeneratorPolynomial.create(10)
      [0, 251, 67, 46, 61, 118, 70, 64, 94, 32, 45]
  """
  @spec create(degree()) :: polynomial()
  def create(degree) when is_integer(degree) and degree in 1..254 do
    degree
    |> roots()
    |> Enum.reduce(&multiply/2)
  end

  defp roots(degree, rts \\ [])
  defp roots(1, rts), do: [[0, 0] | rts]

  defp roots(degree, rts) do
    roots(degree - 1, [[0, degree - 1] | rts])
  end

  defp multiply([0, root], poly) do
    root_multiplied = Enum.map(poly, &GField.add(&1, root))

    [last | _] = Enum.reverse(root_multiplied)

    poly
    |> tl()
    |> Enum.zip(root_multiplied)
    |> Enum.into([0], fn
      {0, 0} -> 0
      {x, y} -> GField.to_a(GField.to_i(x) ^^^ GField.to_i(y))
    end)
    |> Enum.concat([last])
  end
end
