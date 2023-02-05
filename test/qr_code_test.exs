defmodule QRCodeTest do
  @moduledoc false

  use ExUnit.Case

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
        |> QRCode.create!()
        |> QRCode.render()
        |> QRCode.save("/")

      assert rv == {:error, :eisdir}
    end

    test "should raise error when embedded image has not supported mime type" do
      assert_raise ArgumentError, "Bad embedded image format!", fn ->
        wrong_img_format = "/tmp/embedded_img.xxx"
        text = "HELLO WOLRD"

        on_exit(fn ->
          :ok = File.rm(wrong_img_format)
        end)

        {:ok, _} =
          text
          |> QRCode.create!()
          |> QRCode.render(:png)
          |> QRCode.save(wrong_img_format)

        settings = %QRCode.Render.SvgSettings{
          image: {wrong_img_format, 100}
        }

        text
        |> QRCode.create!()
        |> QRCode.render(:svg, settings)
      end
    end
  end
end
