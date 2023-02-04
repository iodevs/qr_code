defmodule DataEncoding.AlphanumericTest do
  use ExUnit.Case, async: true
  use PropCheck
  doctest QRCode.DataEncoding.Alphanumeric

  alias Generators.QR, as: QRGenerator
  alias QRCode.DataEncoding.Alphanumeric
  alias QRCode.{ErrorCorrection, QR}

  # Tests

  test "my test description" do
    qr = %QR{orig: "HELLO WORLD", version: 1, ecc_level: :quartile}

    expected =
      <<0b00100000010110110000101101111000110100010111001011011100010011010100001101000000111011000001000111101100::size(
          104
        )>>

    %QR{encoded: encoded} = Alphanumeric.encode(qr)

    assert byte_size(encoded) == ErrorCorrection.total_data_codewords(qr)
    assert encoded == expected
  end

  # Properties

  property "should contain mode indicator" do
    forall qr <- qr() do
      qr
      |> Alphanumeric.encode()
      |> check_mode_indicator()
    end
  end

  property "should add right byte count" do
    forall qr <- qr() do
      qr
      |> Alphanumeric.encode()
      |> check_character_count()
    end
  end

  property "should have enough bytes" do
    forall qr <- qr() do
      qr
      |> Alphanumeric.encode()
      |> check_total_length()
    end
  end

  property "should fill terminator bits" do
    forall qr <- qr() do
      qr
      |> Alphanumeric.encode()
      |> check_terminator_bits()
    end
  end

  property "should fill pad bits" do
    forall qr <- qr() do
      qr
      |> Alphanumeric.encode()
      |> check_pad_bits()
    end
  end

  property "should fill pad bytes" do
    forall qr <- qr() do
      qr
      |> Alphanumeric.encode()
      |> check_pad_bytes()
    end
  end

  # Helpers

  defp check_mode_indicator(%QR{encoded: <<0b0010::size(4), _::bitstring>>}) do
    true
  end

  defp check_character_count(%QR{version: version, orig: msg, encoded: encoded}) do
    msg_len_bits = get_msg_len_bits(version)

    <<_::size(4), count::size(msg_len_bits), _::bitstring>> = encoded

    byte_size(msg) == count
  end

  defp check_total_length(qr) do
    byte_size(qr.encoded) == ErrorCorrection.total_data_codewords(qr)
  end

  defp check_terminator_bits(%QR{version: version, encoded: encoded}) do
    msg_len_bits = get_msg_len_bits(version)

    <<0b0010::size(4), msg_len::size(msg_len_bits), rest::bitstring>> = encoded

    msg_bitsize = msg_bitsize(msg_len)

    <<_msg::size(msg_bitsize), rest::bitstring>> = rest

    case bit_size(rest) do
      0 ->
        assert match?(<<>>, rest)

      x when x <= 4 ->
        assert match?(<<0::size(x)>>, rest)

      _ ->
        assert match?(<<0::size(4), _::bitstring>>, rest)
    end
  end

  defp check_pad_bits(%QR{version: version, encoded: encoded}) do
    msg_len_bits = get_msg_len_bits(version)

    <<0b0010::size(4), msg_len::size(msg_len_bits), rest::bitstring>> = encoded

    msg_bitsize = msg_bitsize(msg_len)

    <<_msg::size(msg_bitsize), rest::bitstring>> = rest

    rest_size = bit_size(rest)

    case {div(rest_size, 8), rem(rest_size, 8)} do
      {0, 0} ->
        assert match?(<<>>, rest)

      {0, terminator} when terminator <= 4 ->
        # only terminator
        assert match?(<<0::size(terminator)>>, rest)

      {0, pad_bits} when pad_bits > 4 and pad_bits < 8 ->
        # terminator + pad bits
        assert match?(<<0::size(4), 0::size(pad_bits - 4)>>, rest)

      {1, 0} ->
        # 4 bits terminator + 4 bits padding
        assert match?(<<0::size(8)>>, rest)

      _ ->
        # substract terminator
        pad_bits = rem(rest_size - 4, 8)
        assert match?(<<0::size(4), 0::size(pad_bits), _::bitstring>>, rest)
    end
  end

  defp check_pad_bytes(%QR{version: version, encoded: encoded}) do
    msg_len_bits = get_msg_len_bits(version)

    <<0b0010::size(4), msg_len::size(msg_len_bits), rest::bitstring>> = encoded

    msg_bitsize = msg_bitsize(msg_len)

    <<_msg::size(msg_bitsize), rest::bitstring>> = rest

    pad_bytes = get_pad_bytes(rest)
    pad_bytes_count = byte_size(pad_bytes)

    case {div(pad_bytes_count, 2), rem(pad_bytes_count, 2)} do
      {0, 0} ->
        assert pad_bytes == <<>>

      {x, 0} ->
        assert pad_bytes ==
                 <<236, 17>>
                 |> List.duplicate(x)
                 |> Enum.reduce(<<>>, fn item, acc -> <<acc::bitstring, item::bitstring>> end)

      {x, 1} ->
        assert pad_bytes ==
                 <<236, 17>>
                 |> List.duplicate(x)
                 |> Enum.concat([<<236>>])
                 |> Enum.reduce(<<>>, fn item, acc -> <<acc::bitstring, item::bitstring>> end)
    end
  end

  defp get_pad_bytes(rest) do
    rest_size = bit_size(rest)

    case {div(rest_size, 8), rem(rest_size, 8)} do
      {0, 0} ->
        <<>>

      {0, pad_bits} when pad_bits < 8 ->
        <<>>

      {1, 0} ->
        <<>>

      _ ->
        # substract terminator
        pad_bits = rem(rest_size - 4, 8)
        <<0::size(4), 0::size(pad_bits), pad_bytes::bitstring>> = rest
        pad_bytes
    end
  end

  defp msg_bitsize(len) do
    11 * div(len, 2) + 6 * rem(len, 2)
  end

  defp get_msg_len_bits(version) when version < 10, do: 9
  defp get_msg_len_bits(version) when version < 27, do: 11
  defp get_msg_len_bits(_version), do: 13

  # Generators

  def qr() do
    let {level, version} <- {QRGenerator.level(), QRGenerator.version()} do
      lower = QRGenerator.get_capacity_for(:alphanumeric, level, version - 1)
      upper = QRGenerator.get_capacity_for(:alphanumeric, level, version)
      diff = upper - lower
      count = :rand.uniform(diff) + lower

      let message <- QRGenerator.alphanumeric(count) do
        %QR{
          ecc_level: level,
          version: version,
          mode: :alphanumeric,
          orig: message
        }
      end
    end
  end
end
