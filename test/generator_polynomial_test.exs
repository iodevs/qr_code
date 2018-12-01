defmodule GeneratorPolynomialTest do
  @moduledoc false
  use ExUnit.Case
  use PropCheck
  doctest QRCode.GeneratorPolynomial

  alias QRCode.GeneratorPolynomial, as: GP

  property "should return alpha values" do
    forall degree <- integer(1, 254) do
      poly = GP.create(degree)

      assert Enum.all?(poly, fn x -> x in 0..254 end)
    end
  end
end
