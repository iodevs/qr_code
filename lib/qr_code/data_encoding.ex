defmodule QRCode.DataEncoding do
  @moduledoc """
  Decision module for choosing the appropriate encoding.
  """

  alias QRCode.QR

  @spec encode(QR.t()) :: QR.t()
  def encode(%QR{mode: mode} = qr) do
    mode
    |> get_module()
    |> call(qr)
  end

  defp call(module, qr) do
    apply(module, :encode, [qr])
  end

  defp get_module(:byte) do
    QRCode.DataEncoding.ByteEncoding
  end
end
