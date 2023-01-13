defmodule QRCode.DataEncoding.Alphanumeric do
  @moduledoc """
  Encoding codewords for Byte mode.
  """

  alias QRCode.QR

  import QRCode.DataEncoding.Common
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
      |> add_mode_indicator(0b0010)

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
end
