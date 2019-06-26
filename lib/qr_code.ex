defmodule QRCode do
  @moduledoc """
  QR code generator.
  """

  @doc """
  See `QRCode.QR.create/2`
  """
  defdelegate create(text, ecc_level \\ :low), to: QRCode.QR

  @doc """
  See `QRCode.QR.create!/2`
  """
  defdelegate create!(text, ecc_level \\ :low), to: QRCode.QR
end
