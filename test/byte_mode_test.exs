defmodule ByteModeTest do
  @moduledoc false
  use ExUnit.Case
  use PropCheck
  doctest QRCode.Mode.Byte

  alias Generators.QR, as: QRGenerator
  alias QRCode.Mode.Byte
  alias QRCode.QR

  # Tests

  # Properties

  property "should find proper version" do
    forall qr <- qr() do
      qr
      |> Byte.put_version()
      |> check_version(qr.orig, qr.ecc_level)
    end
  end

  # Helpers

  defp check_version({:ok, qr}, message, level) do
    byte_size(message) <= QRGenerator.get_capacity_for(level, qr.version)
  end

  defp check_version({:error, _msg}, message, level) do
    byte_size(message) > QRGenerator.get_capacity_for(level, 40)
  end

  # Generators

  defp qr() do
    let {level, message} <- {QRGenerator.level(), utf8(1500)} do
      %QR{
        ecc_level: level,
        orig: message
      }
    end
  end
end
