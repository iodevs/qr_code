defmodule QRCode.AlphanumericEncoding do
  @moduledoc """
  Encoding codewords for Alphanumeric mode.
  """

  use QRCode.DataEncoding, mode: :alphanumeric

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

  @behaviour QRCode.DataEncoding

  @impl QRCode.DataEncoding
  def encode(%QR{orig: codeword, version: version, ecc_level: level} = qr)
      when level(level) do
    prefix =
      codeword
      |> add_count_indicator(version)
      |> add_mode_indicator()

    # Upcase for to sanitize
    encoded =
      codeword
      |> String.upcase()
      |> convert_chunks()
      |> encode_codeword(prefix)
      |> break_up_into_byte(qr)

    %{qr | encoded: encoded}
  end

  def convert_chunks(codeword, acc \\ [])

  def convert_chunks(<<first::utf8, second::utf8, rest::binary>>, acc)
      when is_map_key(@mapping, first) and is_map_key(@mapping, second) do
    chunk_value = @mapping[first] * 45 + @mapping[second]
    #    padded_chunk = chunk_value |> Integer.to_string(2) |> String.pad_leading(11, "0")
    padded_chunk = <<chunk_value::size(11)>>
    convert_chunks(rest, [padded_chunk | acc])
  end

  def convert_chunks(<<last::utf8>>, acc) when is_map_key(@mapping, last) do
    #    padded_value = @mapping[last] |> Integer.to_string(2) |> String.pad_leading(6, "0")
    padded_value = <<@mapping[last]::size(6)>>
    convert_chunks(<<>>, [padded_value | acc])
  end

  def convert_chunks(<<>>, acc) do
    #    acc |> Enum.reverse() |> List.to_string()
    for chunk <- Enum.reverse(acc), into: <<>>, do: chunk
  end

  def convert_chunks(_codeword, _acc) do
    # Non-alphanumeric character encountered. No good way currently to pass up errors so returning nil
    nil
  end

  #  defp zero_pad(expected_length, chunk) when bit_size(chunk) < expected_length do
  #    <<0::size(expected_length - bit_size(chunk))>>
  #  end
  #
  #  defp zero_pad(expected_length, chunk) do
  #    chunk
  #  end
end
