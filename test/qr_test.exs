defmodule QRTest do
  @moduledoc false
  use ExUnit.Case
  doctest QRCode.QR

  alias QRCode.QR

  test "should raise error when text is too long" do
    assert_raise QRCode.Error, "Input string can't be encoded", fn ->
      5000 |> :crypto.strong_rand_bytes() |> QR.create!()
    end
  end
end
