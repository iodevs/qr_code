defmodule QRCode.ByteEncoding do
  @moduledoc """
  Encoding codewords for Byte mode.
  """

  use QRCode.DataEncoding, mode: :byte

  @behaviour QRCode.DataEncoding

  @impl QRCode.DataEncoding
  def encode(%QR{orig: codeword, version: version, ecc_level: level} = qr)
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
end
