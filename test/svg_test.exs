defmodule SvgTest do
  @moduledoc false

  use ExUnit.Case
  alias QRCode
  alias QRCode.Render.SvgSettings

  @text "HELLO WORLD"
  @dst_to_file "/tmp/hello.svg"
  @rgx_svg_attrs ~r/[xmlns=http:\/\/www.w3.org\/2000\/svg | xlink=http:\/\/www.w3.org\/1999\/xlink]/
  @rgx_qr_color ~r/fill="#11AA88"/
  @rgx_bg_opacity ~r/fill-opacity=/
  @rgx_embedded_image ~r/href="data:image\/png;/

  describe "Svg" do
    setup do
      @text
      |> QRCode.create()
      |> QRCode.render(:svg, %SvgSettings{structure: :readable})
      |> QRCode.save(@dst_to_file)

      on_exit(fn ->
        :ok = File.rm(@dst_to_file)
      end)
    end

    test "render should fail with error" do
      rv =
        Result.error("Error")
        |> QRCode.render()

      assert rv == {:error, "Error"}
    end

    test "should save qr code to svg file" do
      assert File.exists?(@dst_to_file)
    end

    test "should create svg from qr matrix" do
      {:ok, expected} =
        @text
        |> QRCode.create()
        |> QRCode.render(:svg, %SvgSettings{structure: :readable})

      rv =
        @dst_to_file
        |> File.read!()

      assert expected == rv
    end

    test "should encode svg binary to base64" do
      {:ok, expected} =
        @text
        |> QRCode.create()
        |> QRCode.render()

      {:ok, rv} =
        @text
        |> QRCode.create()
        |> QRCode.render()
        |> QRCode.to_base64()
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

    test "file should not contain background opacity" do
      rv =
        @dst_to_file
        |> File.stream!()
        |> Stream.take(2)
        |> Enum.at(1)

      refute Regex.match?(@rgx_bg_opacity, rv)
    end

    test "file should contain background opacity" do
      @text
      |> QRCode.create()
      |> QRCode.render(
        :svg,
        %SvgSettings{background_opacity: 0, structure: :readable}
      )
      |> QRCode.save(@dst_to_file)

      rv =
        @dst_to_file
        |> File.stream!()
        |> Stream.take(2)
        |> Enum.at(1)

      assert Regex.match?(@rgx_bg_opacity, rv)
    end

    test "file should contain embedded image" do
      png_image = "/tmp/embedded_img.png"

      on_exit(fn ->
        :ok = File.rm(png_image)
      end)

      @text
      |> QRCode.create()
      |> QRCode.render(:png)
      |> QRCode.save(png_image)

      settings = %SvgSettings{
        image: {png_image, 100},
        structure: :readable
      }

      @text
      |> QRCode.create()
      |> QRCode.render(:svg, settings)
      |> QRCode.save(@dst_to_file)

      rv =
        @dst_to_file
        |> File.stream!()
        |> Stream.take(-2)
        |> Enum.at(-2)

      assert Regex.match?(@rgx_embedded_image, rv)
    end

    test "file should contain different qr code color than black" do
      @text
      |> QRCode.create()
      |> QRCode.render(
        :svg,
        %SvgSettings{qrcode_color: {17, 170, 136}, structure: :readable}
      )
      |> QRCode.save(@dst_to_file)

      rv =
        @dst_to_file
        |> File.stream!()
        |> Stream.take(3)
        |> Enum.at(-1)

      assert Regex.match?(@rgx_qr_color, rv)
    end
  end
end
