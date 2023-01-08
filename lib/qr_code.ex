defmodule QRCode do
  @moduledoc """
  QR code generator.
  """

  @doc """
  See `QRCode.QR.create/2`
  """
  defdelegate create(text, ecc_level \\ :low, mode \\ :byte), to: QRCode.QR

  @doc """
  See `QRCode.QR.create!/2`
  """
  defdelegate create!(text, ecc_level \\ :low, mode \\ :byte), to: QRCode.QR

  @doc """
  See `QRCode.Render.render/2`
  """
  defdelegate render(qr, render_module \\ :svg),
    to: QRCode.Render

  @doc """
  See `QRCode.Render.render/3`
  """
  defdelegate render(qr, render_module, render_settings),
    to: QRCode.Render

  @doc """
  See `QRCode.Render.to_base64/1`
  """
  defdelegate to_base64(qr_result),
    to: QRCode.Render

  @doc """
  See `QRCode.Render.save/2`
  """
  defdelegate save(qr_result, path_with_file_name),
    to: QRCode.Render
end
