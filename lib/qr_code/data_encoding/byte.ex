defmodule QRCode.DataEncoding.Byte do
  @moduledoc """
  Encoding codewords for Byte mode.
  """

  alias QRCode.QR

  import QRCode.DataEncoding.Common
  import QRCode.QR, only: [level: 1]

  @spec encode(QR.t()) :: QR.t()
  def encode(%QR{orig: codeword, version: version, ecc_level: level} = qr)
      when level(level) do
    prefix =
      codeword
      |> add_count_indicator(version)
      |> add_mode_indicator(0b0100)

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
end
