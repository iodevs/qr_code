defmodule GeneratorPolynomialTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use PropCheck
  doctest QRCode.GeneratorPolynomial

  alias QRCode.GeneratorPolynomial, as: GP

  @tag timeout: 180_000
  property "should return alpha values" do
    forall degree <- integer(1, 254) do
      poly = GP.create(degree)

      assert Enum.all?(poly, fn x -> x in 0..254 end)
    end
  end

  @tag timeout: 180_000
  property "should have degree+1 values" do
    forall degree <- integer(1, 254) do
      count = Enum.count(GP.create(degree))

      assert count == degree + 1
    end
  end
end
