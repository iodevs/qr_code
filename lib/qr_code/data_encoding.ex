defmodule QRCode.DataEncoding do
  @moduledoc """
  Encoding codewords common to all modes.
  """

  import QRCode.QR, only: [level: 1]
  alias QRCode.{AlphanumericEncoding, ByteEncoding, ErrorCorrection, QR}

  @callback encode(QR.t()) :: QR.t()

  @modes [:byte, :alphanumeric]

  defguardp is_mode(value) when value in @modes

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import QRCode.QR, only: [level: 1]
      alias QRCode.{CharacterCapacity, DataEncoding, ErrorCorrection, QR}

      @mode Keyword.fetch!(opts, :mode)

      defp add_count_indicator(codeword, version) do
        trim_to = DataEncoding.count_bit_length(@mode, version)

        <<byte_size(codeword)::size(trim_to)>>
      end

      defp add_mode_indicator(codeword) do
        mode_binary = DataEncoding.mode_indicator_byte(@mode)

        <<(<<mode_binary::size(4)>>), codeword::bitstring>>
      end

      defp encode_codeword(codeword, prefix) do
        <<prefix::bitstring, codeword::bitstring>>
      end

      defp break_up_into_byte(codeword, qr) do
        is_string_long_enough = diff_total_number_and_bit_size_cw(codeword, qr)

        if is_string_long_enough == 0 do
          codeword
        else
          codeword
          |> add_terminator(qr)
          |> add_pad_bits(qr)
          |> add_pad_bytes(qr)
        end
      end

      defp add_terminator(codeword, qr) do
        left_to_pad = diff_total_number_and_bit_size_cw(codeword, qr)

        # pad a maximum of 4 zeros as a terminator if necessary
        cond do
          left_to_pad == 0 -> codeword
          left_to_pad >= 4 -> <<codeword::bitstring, (<<0::size(4)>>)>>
          true -> <<codeword::bitstring, (<<0::size(left_to_pad)>>)>>
        end
      end

      defp add_pad_bits(codeword, qr) when not is_binary(codeword) do
        bit_remainder = 8 - rem(bit_size(codeword), 8)
        <<codeword::bitstring, (<<0::size(bit_remainder)>>)>>
      end

      defp add_pad_bits(codeword, qr) do
        codeword
      end

      defp add_pad_bytes(codeword, qr) do
        is_string_long_enough = diff_total_number_and_bit_size_cw(codeword, qr)

        if is_string_long_enough == 0 do
          codeword
        else
          fill_to_max = div(is_string_long_enough, 8)
          <<codeword::bitstring, add_specification(fill_to_max)::bitstring>>
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
  end

  def mode_indicator_byte(mode) when is_mode(mode) do
    case mode do
      :numeric -> 0b0001
      :alphanumeric -> 0b0010
      :byte -> 0b0100
      :kanji -> 0b1000
      :eci -> 0b0111
    end
  end

  def count_bit_length(mode, version) when is_mode(mode) and version < 10 do
    case mode do
      :numeric -> 10
      :alphanumeric -> 9
      :byte -> 8
      :kanji -> 8
    end
  end

  def count_bit_length(mode, version) when is_mode(mode) and version < 27 do
    case mode do
      :numeric -> 12
      :alphanumeric -> 11
      :byte -> 16
      :kanji -> 10
    end
  end

  def count_bit_length(mode, version) when is_mode(mode) and version <= 40 do
    case mode do
      :numeric -> 14
      :alphanumeric -> 13
      :byte -> 16
      :kanji -> 12
    end
  end

  @spec encode(QR.t()) :: QR.t()
  def encode(%QR{mode: :byte} = qr) do
    ByteEncoding.encode(qr)
  end

  @spec encode(QR.t()) :: QR.t()
  def encode(%QR{mode: :alphanumeric} = qr) do
    AlphanumericEncoding.encode(qr)
  end
end
