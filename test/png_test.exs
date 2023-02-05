defmodule PngTest do
  @moduledoc false

  use ExUnit.Case
  alias QRCode
  alias QRCode.Render.PngSettings

  @text "HELLO WORLD"
  @dst_to_file "/tmp/hello.png"

  describe "Png" do
    setup do
      @text
      |> QRCode.create!()
      |> QRCode.render(:png)
      |> QRCode.save(@dst_to_file)

      on_exit(fn ->
        :ok = File.rm(@dst_to_file)
      end)
    end

    test "should save qr code to png file" do
      assert File.exists?(@dst_to_file)
    end

    test "should create png from qr matrix" do
      expected =
        @text
        |> QRCode.create!()
        |> QRCode.render(:png)

      rv =
        @dst_to_file
        |> File.read!()

      assert expected == rv
    end

    test "should encode png binary to base64" do
      rendered_qr =
        @text
        |> QRCode.create!()
        |> QRCode.render(:png)

      rv =
        rendered_qr
        |> QRCode.to_base64()
        |> Base.decode64!()

      assert rv == rendered_qr
    end

    test "file should contain different qr code color than black" do
      expected =
        @text
        |> QRCode.create!()
        |> QRCode.render(
          :png,
          %PngSettings{qrcode_color: {17, 170, 136}}
        )

      {:ok, _} = QRCode.save(expected, @dst_to_file)

      rv =
        @dst_to_file
        |> File.read!()

      assert expected == rv
    end
  end
end
