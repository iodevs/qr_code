defmodule ByteEncodingTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use PropCheck

  doctest QRCode.ByteEncoding

  alias QRCode.{ByteEncoding, DataEncoding, ErrorCorrection, QR}
  alias Generators.QR, as: QRGenerator

  # Tests

  # Properties

  property "should contain mode indicator" do
    forall qr <- qr() do
      qr
      |> ByteEncoding.encode()
      |> check_mode_indicator()
    end
  end

  property "should add right byte count" do
    forall qr <- qr() do
      qr
      |> ByteEncoding.encode()
      |> check_character_count()
    end
  end

  property "should have enough bytes" do
    forall qr <- qr() do
      qr
      |> ByteEncoding.encode()
      |> check_total_length()
    end
  end

  property "should fill pad bytes" do
    forall qr <- qr() do
      qr
      |> ByteEncoding.encode()
      |> check_pad_bytes()
    end
  end

  # Helpers

  defp check_mode_indicator(%QR{
         mode: mode,
         encoded: <<mode_indicator::size(4), _::bitstring>>
       }) do
    mode_indicator == DataEncoding.mode_indicator_byte(mode)
  end

  defp check_character_count(%QR{orig: msg} = qr) do
    message_size_bits = DataEncoding.count_bit_length(qr.mode, qr.version)
    <<_::size(4), count::size(message_size_bits), _::bitstring>> = qr.encoded
    byte_size(msg) == count
  end

  defp check_total_length(qr) do
    byte_size(qr.encoded) == ErrorCorrection.total_data_codewords(qr)
  end

  defp check_pad_bytes(%QR{} = qr) do
    count = byte_size(qr.orig) * 8
    mode_indicator = DataEncoding.mode_indicator_byte(qr.mode)
    message_size_bits = DataEncoding.count_bit_length(qr.mode, qr.version)

    <<^mode_indicator::size(4), _c::size(message_size_bits), _msg::size(count), 0b0000::size(4),
      rest::bitstring>> = qr.encoded

    rest_count = byte_size(rest)

    case {div(rest_count, 2), rem(rest_count, 2)} do
      {0, 0} ->
        rest == <<>>

      {x, 0} ->
        rest ==
          <<236, 17>>
          |> List.duplicate(x)
          |> Enum.reduce(<<>>, fn item, acc -> <<acc::bitstring, item::bitstring>> end)

      {x, 1} ->
        rest ==
          <<236, 17>>
          |> List.duplicate(x)
          |> Enum.concat([<<236>>])
          |> Enum.reduce(<<>>, fn item, acc -> <<acc::bitstring, item::bitstring>> end)
    end
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
          orig: message,
          mode: :byte
        }
      end
    end
  end
end
