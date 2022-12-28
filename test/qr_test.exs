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

  test "should raise error when embedded image has not supported mime type" do
    assert_raise ArgumentError, "Bad embedded image format!", fn ->
      wrong_img_format = "/tmp/embedded_img.xxx"
      text = "HELLO WOLRD"

      on_exit(fn ->
        :ok = File.rm(wrong_img_format)
      end)

      text
      |> QRCode.create()
      |> QRCode.render(:png)
      |> QRCode.save(wrong_img_format)

      settings = %QRCode.Render.SvgSettings{
        image: {wrong_img_format, 100}
      }

      text
      |> QRCode.create()
      |> QRCode.render(:svg, settings)
    end
  end
end
