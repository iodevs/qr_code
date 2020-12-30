defmodule SvgTest do
  @moduledoc false

  use ExUnit.Case
  alias QRCode.{QR, Svg, SvgSettings}

  @text "HELLO WORLD"
  @dst_to_file "/tmp/hello.svg"
  @rgx_svg_attrs ~r/[xmlns=http:\/\/www.w3.org\/2000\/svg | xlink=http:\/\/www.w3.org\/1999\/xlink]/
  @rgx_qr_color ~r/fill="#11AA88"/
  @rgx_bg_transparency ~r/fill-opacity=/

  describe "Svg" do
    setup do
      @text
      |> QR.create()
      |> Result.and_then(&Svg.save_as(&1, @dst_to_file, %SvgSettings{format: :indent}))

      on_exit(fn ->
        :ok = File.rm(@dst_to_file)
      end)
    end

    test "should save qr code to svg file" do
      assert File.exists?(@dst_to_file)
    end

    test "should create svg from qr matrix" do
      expected =
        @text
        |> QR.create()
        |> Result.and_then(&Svg.create(&1, %SvgSettings{format: :indent}))

      rv =
        @dst_to_file
        |> File.read!()

      assert expected == rv
    end

    test "should encoded svg binary to base64" do
      expected =
        @text
        |> QR.create()
        |> Result.and_then(&Svg.create/1)

      {:ok, rv} =
        @text
        |> QR.create()
        |> Result.map(&Svg.to_base64/1)
        |> Result.and_then(&Base.decode64/1)

      assert expected == rv
    end

    test "file should contain xmlns and xlink attributes" do
      rv =
        @dst_to_file
        |> File.stream!()
        |> Stream.take(2)
        |> Enum.at(0)

      assert Regex.match?(@rgx_svg_attrs, rv)
    end

    test "file should not contain backgound transparency" do
      rv =
        @dst_to_file
        |> File.stream!()
        |> Stream.take(2)
        |> Enum.at(1)

      refute Regex.match?(@rgx_bg_transparency, rv)
    end

    test "file should contain backgound transparency" do
      @text
      |> QR.create()
      |> Result.and_then(
        &Svg.save_as(
          &1,
          @dst_to_file,
          %SvgSettings{background_transparency: 0, format: :indent}
        )
      )

      rv =
        @dst_to_file
        |> File.stream!()
        |> Stream.take(2)
        |> Enum.at(1)

      assert Regex.match?(@rgx_bg_transparency, rv)
    end

    test "file should contain different qr code color than black" do
      @text
      |> QR.create()
      |> Result.and_then(
        &Svg.save_as(
          &1,
          @dst_to_file,
          %SvgSettings{qrcode_color: {17, 170, 136}, format: :indent}
        )
      )

      rv =
        @dst_to_file
        |> File.stream!()
        |> Stream.take(3)
        |> Enum.at(-1)

      assert Regex.match?(@rgx_qr_color, rv)
    end
  end
end
