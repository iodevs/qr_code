defmodule QRCode.DataEncoding.Common do
  @moduledoc """
  A common functions for all encodings.
  """

  alias QRCode.ErrorCorrection

  def add_mode_indicator(codeword, mode_indicator) do
    <<(<<mode_indicator::size(4)>>), codeword::bitstring>>
  end

  def encode_codeword(codeword, prefix) do
    <<prefix::bitstring, codeword::bitstring>>
  end

  def break_up_into_byte(codeword, qr) do
    max_capacity = max_capacity_in_bits(qr)

    codeword
    |> add_terminator(max_capacity)
    |> add_pad_bits()
    |> add_pad_bytes(max_capacity)
  end

  defp add_terminator(codeword, max_capacity) do
    case diff_total_number_and_bit_size_cw(codeword, max_capacity) do
      0 -> codeword
      x when x < 4 -> <<codeword::bitstring, (<<0::size(x)>>)>>
      _ -> <<codeword::bitstring, (<<0::size(4)>>)>>
    end
  end

  defp add_pad_bits(codeword) do
    count = compute_pad_bits(codeword)

    <<codeword::bitstring, 0::size(count)>>
  end

  defp compute_pad_bits(codeword) do
    case rem(bit_size(codeword), 8) do
      0 -> 0
      val -> 8 - val
    end
  end

  defp add_pad_bytes(codeword, max_capacity) do
    is_string_long_enough = diff_total_number_and_bit_size_cw(codeword, max_capacity)

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

  defp diff_total_number_and_bit_size_cw(codeword, max_capacity)
       when is_integer(max_capacity) and max_capacity > 0 and rem(max_capacity, 8) == 0 do
    max_capacity - bit_size(codeword)
  end

  defp max_capacity_in_bits(qr) do
    ErrorCorrection.total_data_codewords(qr) * 8
  end
end
