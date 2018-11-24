defmodule QRCode.DataEncoding do
  @moduledoc """
  Encoding codewords for Byte mode.
  """

  alias QRCode.{ErrorCorrection, Version}

  @spec break_up_into_byte(String.t(), Version.t(), ErrorCorrection.level()) ::
          Result.t(String.t(), <<_::_*8>>)
  def break_up_into_byte(codeword, version, level) when version <= 40 do
    codeword
    |> add_count_indicator(version)
    |> add_mode_indicator()
    |> add_terminator(version, level)
    |> add_more_zeros()
    |> add_pad_bytes(version, level)
    |> (&{:ok, &1}).()
  end

  def break_up_into_byte(version, _version, _level) when 40 < version do
    {:error, "You have to use codewords length less than 2953 characters."}
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

  defp add_terminator(codeword, version, level) do
    total_number = required_number(version, level)

    case abs(total_number - bit_size(codeword)) do
      1 -> <<codeword::bitstring, (<<0b0::size(1)>>)>>
      2 -> <<codeword::bitstring, (<<0b00::size(2)>>)>>
      3 -> <<codeword::bitstring, (<<0b000::size(3)>>)>>
      4 -> <<codeword::bitstring, (<<0b0000::size(4)>>)>>
      _ -> codeword
    end
  end

  defp add_more_zeros(codeword) do
    reminder = rem(bit_size(codeword), 8)

    case reminder do
      0 -> codeword
      _ -> <<codeword::bitstring, (<<reminder::size(reminder)>>)>>
    end
  end

  defp add_pad_bytes(codeword, version, level) do
    fill_to_max =
      required_number(version, level)
      |> Kernel.-(bit_size(codeword))
      |> Kernel.rem(8)

    case fill_to_max do
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

  defp required_number(version, level) do
    ErrorCorrection.total_data_codewords(version, level) * 8
  end
end
