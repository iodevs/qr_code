defmodule AlphanumericEncodingTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use PropCheck
  doctest QRCode.AlphanumericEncoding

  alias QRCode.{AlphanumericEncoding, ErrorCorrection, DataEncoding, QR}
  alias Generators.QR, as: QRGenerator

  @encoded_pair_length 11
  @encoded_single_length 6

  # Tests

  # Properties

  property "should contain mode indicator" do
    forall qr <- qr() do
      qr
      |> AlphanumericEncoding.encode()
      |> check_mode_indicator()
    end
  end

  property "should add right byte count" do
    forall qr <- qr() do
      qr
      |> AlphanumericEncoding.encode()
      |> check_character_count()
    end
  end

  property "should have enough bytes" do
    forall qr <- qr() do
      qr
      |> AlphanumericEncoding.encode()
      |> check_total_length()
    end
  end

  property "should fill pad bytes" do
    forall qr <- qr() do
      qr
      |> AlphanumericEncoding.encode()
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

  defp calculate_message_length(orig) when rem(byte_size(orig), 2) != 0 do
    # encoded data is in 11 bit chunks of two characters with an additional
    # 6 bit chunk if an odd number of characters
    div(byte_size(orig), 2) * @encoded_pair_length + @encoded_single_length
  end

  defp calculate_message_length(orig) do
    div(byte_size(orig), 2) * @encoded_pair_length
  end

  defp strip_zeros(bytes) when rem(bit_size(bytes), 8) != 0 do
    <<_zeros::size(rem(bit_size(bytes), 8)), padding::bitstring>> = bytes
    strip_zeros(padding)
  end

  defp strip_zeros(<<0, bytes::binary>>) do
    bytes
  end

  defp strip_zeros(bytes) when is_binary(bytes) do
    bytes
  end

  defp check_pad_bytes(%QR{} = qr) do
    message_length = calculate_message_length(qr.orig)
    mode_indicator = DataEncoding.mode_indicator_byte(qr.mode)
    message_size_bits = DataEncoding.count_bit_length(qr.mode, qr.version)

    <<^mode_indicator::size(4), _raw_count::size(message_size_bits),
      _msg::bitstring-size(message_length), rest::bitstring>> = qr.encoded

    padding = strip_zeros(rest)

    rest_count = byte_size(padding)

    case {div(rest_count, 2), rem(rest_count, 2)} do
      {0, 0} ->
        padding == <<>>

      {x, 0} ->
        padding ==
          <<236, 17>>
          |> List.duplicate(x)
          |> Enum.reduce(<<>>, fn item, acc -> <<acc::bitstring, item::bitstring>> end)

      {x, 1} ->
        padding ==
          <<236, 17>>
          |> List.duplicate(x)
          |> Enum.concat([<<236>>])
          |> Enum.reduce(<<>>, fn item, acc -> <<acc::bitstring, item::bitstring>> end)
    end
  end

  # Generators

  defp alphanumeric(size) when size > 0 do
    for _ <- 1..size,
        into: "",
        do: <<Enum.random('0123456789ABCDEFGHIJKLMNOPQRZSTUVWXYZ $%*+-./:')>>
  end

  def qr() do
    let {level, version} <- {QRGenerator.level(), QRGenerator.version()} do
      lower = QRGenerator.get_capacity_for(level, version - 1, :alphanumeric)
      upper = QRGenerator.get_capacity_for(level, version, :alphanumeric)
      diff = upper - lower
      count = :rand.uniform(diff) + lower

      let message <- alphanumeric(count) do
        %QR{
          ecc_level: level,
          version: version,
          orig: message,
          mode: :alphanumeric
        }
      end
    end
  end
end
