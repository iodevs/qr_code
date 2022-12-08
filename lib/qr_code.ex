defmodule QRCode do
  @moduledoc """
  QR code generator.
  """

  @doc """
  See `QRCode.QR.create/3`
  """
  defdelegate create(text, ecc_level \\ :low, mode \\ :byte), to: QRCode.QR

  @doc """
  See `QRCode.QR.create!/3`
  """
  defdelegate create!(text, ecc_level \\ :low, mode \\ :byte), to: QRCode.QR

end
