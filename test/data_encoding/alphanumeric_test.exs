defmodule DataEncoding.AlphanumericTest do
  use ExUnit.Case, async: true
  doctest QRCode.DataEncoding.Alphanumeric

  alias QRCode.DataEncoding.Alphanumeric
  alias QRCode.{ErrorCorrection, QR}

  test "my test description" do
    qr = %QR{orig: "HELLO WORLD", version: 1, ecc_level: :quartile}

    expected =
      <<0b00100000010110110000101101111000110100010111001011011100010011010100001101000000111011000001000111101100::size(
          104
        )>>

    %QR{encoded: encoded} = Alphanumeric.encode(qr)

    assert byte_size(encoded) == ErrorCorrection.total_data_codewords(qr)
    assert encoded == expected
  end
end
