defmodule GaloisFieldTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use PropCheck
  doctest QRCode.GaloisField

  alias QRCode.GaloisField

  property "should convert log to antilog values and back" do
    forall alpha <- integer(0, 254) do
      assert GaloisField.to_a(GaloisField.to_i(alpha)) == alpha
    end
  end
end
