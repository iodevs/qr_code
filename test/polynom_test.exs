defmodule PolynomTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use PropCheck
  doctest QRCode.Polynom

  alias QRCode.Polynom
  alias QRCode.GeneratorPolynomial, as: GP

  property "should compute division of two polynomials" do
    forall {dividend, expected, divisor} <- examples() do
      Polynom.div(dividend, GP.create(divisor)) == expected
    end
  end

  # Generators
  defp examples() do
    oneof([
      {
        [67, 85, 70, 134, 87, 38, 85, 194, 119, 50, 6, 18, 6, 103, 38],
        [213, 199, 11, 45, 115, 247, 241, 223, 229, 248, 154, 117, 154, 111, 86, 161, 111, 39],
        18
      },
      {
        [246, 246, 66, 7, 118, 134, 242, 7, 38, 86, 22, 198, 199, 146, 6],
        [87, 204, 96, 60, 202, 182, 124, 157, 200, 134, 27, 129, 209, 17, 163, 163, 120, 133],
        18
      },
      {
        [182, 230, 247, 119, 50, 7, 118, 134, 87, 38, 82, 6, 134, 151, 50, 7],
        [148, 116, 177, 212, 76, 133, 75, 242, 238, 76, 195, 230, 189, 10, 108, 240, 192, 141],
        18
      },
      {
        [70, 247, 118, 86, 194, 6, 151, 50, 16, 236, 17, 236, 17, 236, 17, 236],
        [235, 159, 5, 173, 24, 147, 59, 33, 106, 40, 255, 172, 82, 2, 131, 32, 178, 236],
        18
      },
      {
        [135, 146, 7, 70, 87, 135, 66, 194, 7, 70, 22, 183],
        [
          118,
          228,
          136,
          160,
          251,
          17,
          221,
          168,
          22,
          43,
          111,
          194,
          140,
          103,
          43,
          36,
          60,
          71,
          147,
          175,
          14,
          48,
          204,
          0
        ],
        24
      }
    ])
  end
end
