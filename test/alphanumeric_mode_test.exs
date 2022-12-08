defmodule AlphanumericModeTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use PropCheck
  doctest QRCode.AlphanumericMode

  alias QRCode.{AlphanumericMode, QR}
  alias Generators.QR, as: QRGenerator

  # Tests

  # Properties

  property "should find proper version" do
    forall qr <- qr() do
      qr
      |> AlphanumericMode.put_version()
      |> check_version(qr.orig, qr.ecc_level)
    end
  end

  # Helpers

  defp check_version({:ok, qr}, message, level) do
    byte_size(message) <= QRGenerator.get_capacity_for(level, qr.version, :alphanumeric)
  end

  defp check_version({:error, _msg}, message, level) do
    byte_size(message) > QRGenerator.get_capacity_for(level, 40, :alphanumeric)
  end

  # Generators
  defp alphanumeric(size) when size > 0 do
    for _ <- 1..size,
        into: "",
        do: <<Enum.random('0123456789ABCDEFGHIJKLMNOPQRZSTUVWXYZ $%*+-./:')>>
  end

  defp qr() do
    let {level, message} <- {QRGenerator.level(), alphanumeric(1500)} do
      %QR{
        ecc_level: level,
        orig: message,
        mode: :alphanumeric
      }
    end
  end
end
