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

  property "should has result with correct number of terms" do
    forall {degree, msg} <- {integer(1, 68), list(byte())} do
      msg
      |> Polynom.div(GP.create(degree))
      |> check_degree(degree)
    end
  end

  # Helpers

  defp check_degree(result, degree) do
    length(result) == degree
  end

  # Generators

  defp examples() do
    oneof([
      {
        [
          122,
          164,
          87,
          113,
          7,
          246,
          187,
          225,
          140,
          37,
          138,
          184,
          190,
          109,
          152,
          57,
          10,
          21,
          3,
          1,
          140,
          121,
          29,
          20,
          80
        ],
        [
          0,
          160,
          11,
          203,
          30,
          9,
          168,
          142,
          17,
          154,
          199,
          21,
          178,
          53,
          138,
          13,
          139,
          171,
          212,
          226,
          58,
          162,
          108,
          195,
          198,
          25,
          75,
          151,
          101,
          68
        ],
        30
      },
      {
        [64, 86, 22, 134, 246, 166, 240, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17],
        [151, 167, 214, 123, 140, 176, 135],
        7
      },
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
