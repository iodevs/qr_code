defmodule QRCode.DataEncoding.Alphanumeric do
  @moduledoc """
  Encoding codewords for Byte mode.
  """

  alias QRCode.{ErrorCorrection, QR}
  import QRCode.QR, only: [level: 1]

  @mapping %{
    ?0 => 0,
    ?1 => 1,
    ?2 => 2,
    ?3 => 3,
    ?4 => 4,
    ?5 => 5,
    ?6 => 6,
    ?7 => 7,
    ?8 => 8,
    ?9 => 9,
    ?A => 10,
    ?B => 11,
    ?C => 12,
    ?D => 13,
    ?E => 14,
    ?F => 15,
    ?G => 16,
    ?H => 17,
    ?I => 18,
    ?J => 19,
    ?K => 20,
    ?L => 21,
    ?M => 22,
    ?N => 23,
    ?O => 24,
    ?P => 25,
    ?Q => 26,
    ?R => 27,
    ?S => 28,
    ?T => 29,
    ?U => 30,
    ?V => 31,
    ?W => 32,
    ?X => 33,
    ?Y => 34,
    ?Z => 35,
    ?\s => 36,
    ?$ => 37,
    ?% => 38,
    ?* => 39,
    ?+ => 40,
    ?- => 41,
    ?. => 42,
    ?/ => 43,
    ?: => 44
  }

  @spec encode(QR.t()) :: QR.t()
  def encode(%QR{orig: codeword, version: version, ecc_level: level} = qr)
      when level(level) do
    prefix =
      codeword
      |> add_count_indicator(version)
      |> add_mode_indicator()

    encoded =
      codeword
      |> upcase()
      |> translate()
      |> split_to_pairs()
      |> compute_representation()
      |> encode_codeword(prefix)
      |> break_up_into_byte(qr)

    %{qr | encoded: encoded}
  end

  defp upcase(codeword) do
    String.upcase(codeword)
  end

  defp split_to_pairs(mapped_chars) do
    Enum.chunk_every(mapped_chars, 2)
  end

  defp translate(codeword) do
    codeword
    |> String.to_charlist()
    |> Enum.map(&translate_char/1)
  end

  defp translate_char(char) do
    @mapping[char]
  end

  defp compute_representation(pairs) do
    Enum.reduce(
      pairs,
      <<>>,
      fn
        [h, l], acc -> <<acc::bitstring, h * 45 + l::size(11)>>
        [l], acc -> <<acc::bitstring, l::size(6)>>
      end
    )
  end

  defp add_count_indicator(codeword, version) when version < 10 do
    <<byte_size(codeword)::size(9)>>
  end

  defp add_count_indicator(codeword, version) when version < 27 do
    <<byte_size(codeword)::size(11)>>
  end

  defp add_count_indicator(codeword, _version) do
    <<byte_size(codeword)::size(13)>>
  end

  defp add_mode_indicator(codeword) do
    <<(<<0b0010::size(4)>>), codeword::bitstring>>
  end

  defp encode_codeword(codeword, prefix) do
    <<prefix::bitstring, codeword::bitstring>>
  end

  defp break_up_into_byte(codeword, qr) do
    codeword
    |> add_terminator()
    |> add_pad_bits()
    |> add_pad_bytes(qr)
  end

  defp add_terminator(codeword) do
    <<codeword::bitstring, (<<0::size(4)>>)>>
  end

  defp add_pad_bits(codeword) do
    count = 8 - rem(bit_size(codeword), 8)

    <<codeword::bitstring, 0::size(count)>>
  end

  defp add_pad_bytes(codeword, qr) do
    is_string_long_enough = diff_total_number_and_bit_size_cw(codeword, qr)

    fill_to_max =
      is_string_long_enough
      |> div(8)

    case is_string_long_enough do
      0 -> codeword
      _ -> <<codeword::bitstring, add_specification(fill_to_max)::bitstring>>
    end
  end

  defp add_specification(fill_to_max) do
    1..fill_to_max
    |> Enum.map(fn x -> rem(x, 2) end)
    |> Enum.reduce(<<>>, fn
      x, acc when x == 0 -> acc <> <<17>>
      x, acc when x == 1 -> acc <> <<236>>
    end)
  end

  defp diff_total_number_and_bit_size_cw(codeword, qr) do
    ErrorCorrection.total_data_codewords(qr) * 8 - bit_size(codeword)
  end
end
