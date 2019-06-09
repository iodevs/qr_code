defmodule DataEncodingTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use PropCheck
  doctest QRCode.DataEncoding

  alias QRCode.{DataEncoding, ErrorCorrection, QR}
  alias Generators.QR, as: QRGenerator

  # Tests

  # Properties

  property "should contain mode indicator" do
    forall qr <- qr() do
      qr
      |> DataEncoding.byte_encode()
      |> check_mode_indicator()
    end
  end

  property "should add right byte count" do
    forall qr <- qr() do
      qr
      |> DataEncoding.byte_encode()
      |> check_character_count()
    end
  end

  property "should have enough bytes" do
    forall qr <- qr() do
      qr
      |> DataEncoding.byte_encode()
      |> check_total_length()
    end
  end

  # Helpers

  defp check_mode_indicator(%QR{encoded: <<0b0100::size(4), _::bitstring>>}) do
    true
  end

  defp check_character_count(%QR{
         version: version,
         orig: msg,
         encoded: <<_::size(4), count::size(8), _::bitstring>>
       })
       when version < 10 do
    byte_size(msg) == count
  end

  defp check_character_count(%QR{
         orig: msg,
         encoded: <<_::size(4), count::size(16), _::bitstring>>
       }) do
    byte_size(msg) == count
  end

  defp check_total_length(qr) do
    byte_size(qr.encoded) == ErrorCorrection.total_data_codewords(qr)
  end

  # Generators

  def qr() do
    let {level, version} <- {QRGenerator.level(), QRGenerator.version()} do
      lower = QRGenerator.get_capacity_for(level, version - 1)
      upper = QRGenerator.get_capacity_for(level, version)
      diff = upper - lower
      count = :rand.uniform(diff) + lower

      let message <- binary(count) do
        %QR{
          ecc_level: level,
          version: version,
          orig: message
        }
      end
    end
  end
end
