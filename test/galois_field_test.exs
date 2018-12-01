defmodule GaloisFieldTest do
  @moduledoc false
  use ExUnit.Case
  doctest QRCode.GaloisField

  alias QRCode.GaloisField

  test "should convert log to antilog values and back" do
    0..254
    |> Enum.map(fn alpha -> assert GaloisField.to_a(GaloisField.to_i(alpha)) == alpha end)
  end
end
