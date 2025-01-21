defmodule QRCodeTest do
  @moduledoc false

  use ExUnit.Case, async: true

  @dst_to_file "/tmp/hello.svg"

  describe "QRCode" do
    test "should create! QR" do
      rv = QRCode.create!("text")

      assert rv.mode == :byte
      assert rv.ecc_level == :low

      assert rv.encoded ==
               <<64, 71, 70, 87, 135, 64, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17,
                 236>>

      assert rv.message ==
               <<64, 71, 70, 87, 135, 64, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17,
                 236, 99, 253, 15, 156, 11, 192, 251>>
    end

    test "should fail to save qr code bc of wrong file name" do
      rv =
        "text"
        |> QRCode.create()
        |> QRCode.render()
        |> QRCode.save("/")

      assert elem(rv, 0) == :error
    end

    test "should fail to save qr code to file" do
      rv =
        Result.error("Error")
        |> QRCode.save(@dst_to_file)

      assert rv == {:error, "Error"}
    end

    test "should fail to encode qr to base 64" do
      rv =
        Result.error("Error")
        |> QRCode.to_base64()

      assert rv == {:error, "Error"}
    end
  end
end
