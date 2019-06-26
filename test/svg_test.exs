defmodule SvgTest do
  @moduledoc false

  use ExUnit.Case
  alias QRCode.{QR, Svg}

  @text "HELLO WORLD"
  @dst_to_file "/tmp/hello.svg"
  @rgx_svg_attrs ~r/[xmlns=http:\/\/www.w3.org\/2000\/svg | xlink=http:\/\/www.w3.org\/1999\/xlink]/
  @rgx_qr_color ~r/fill="#11AA88"/

  describe "Svg" do
    setup do
      @text
      |> QR.create()
      |> Result.and_then(&Svg.save_as(&1, @dst_to_file))

      on_exit(fn ->
        :ok = File.rm(@dst_to_file)
      end)
    end

    test "should save qr code to svg file" do
      assert File.exists?(@dst_to_file)
    end

    test "file should contain xmlns and xlink attributes" do
      rv =
        @dst_to_file
        |> File.stream!()
        |> Stream.take(2)
        |> Enum.at(0)

      assert Regex.match?(@rgx_svg_attrs, rv)
    end

    test "file should contain different qr code color than black" do
      @text
      |> QR.create()
      |> Result.and_then(
        &Svg.save_as(&1, @dst_to_file, %QRCode.SvgSettings{qrcode_color: {17, 170, 136}})
      )

      color =
        @dst_to_file
        |> File.stream!()
        |> Stream.take(3)
        |> Enum.at(-1)

      assert Regex.match?(@rgx_qr_color, color)
    end
  end
end
