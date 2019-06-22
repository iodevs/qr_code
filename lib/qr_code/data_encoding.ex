defmodule QRCode.DataEncoding do
  @moduledoc """
  Encoding codewords for Byte mode.
  """

  alias QRCode.{ErrorCorrection, QR}
  import QRCode.QR, only: [level: 1]

  @spec byte_encode(QR.t()) :: QR.t()
  def byte_encode(%QR{orig: codeword, version: version, ecc_level: level} = qr)
      when level(level) do
    prefix =
      codeword
      |> add_count_indicator(version)
      |> add_mode_indicator()

    encoded =
      codeword
      |> encode_codeword(prefix)
      |> break_up_into_byte(qr)

    %{qr | encoded: encoded}
  end

  defp add_count_indicator(codeword, version) when version < 10 do
    <<byte_size(codeword)::size(8)>>
  end

  defp add_count_indicator(codeword, _version) do
    <<byte_size(codeword)::size(16)>>
  end

  defp add_mode_indicator(codeword) do
    <<(<<0b0100::size(4)>>), codeword::bitstring>>
  end

  defp encode_codeword(codeword, prefix) do
    <<prefix::bitstring, codeword::bitstring>>
  end

  defp break_up_into_byte(codeword, qr) do
    codeword
    |> add_terminator()
    |> add_pad_bytes(qr)
  end

  defp add_terminator(codeword) do
    <<codeword::bitstring, (<<0::size(4)>>)>>
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
