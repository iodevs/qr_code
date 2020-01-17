defmodule PngTest do
  @moduledoc false

  use ExUnit.Case
  alias QRCode.{Png, PngSettings, QR}

  @text "HELLO WORLD"
  @dst_to_file "/tmp/hello.png"

  describe "Png" do
    setup do
      @text
      |> QR.create()
      |> Result.and_then(&Png.save_as(&1, @dst_to_file, %PngSettings{}))

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
        |> QR.create()
        |> Result.and_then(&Png.create(&1, %PngSettings{}))

      rv =
        @dst_to_file
        |> File.read!()

      assert expected == rv
    end

    test "should encoded png binary to base64" do
      expected =
        @text
        |> QR.create()
        |> Result.and_then(&Png.create/1)

      {:ok, rv} =
        @text
        |> QR.create()
        |> Result.map(&Png.to_base64/1)
        |> Result.and_then(&Base.decode64/1)

      assert expected == rv
    end
  end
end
