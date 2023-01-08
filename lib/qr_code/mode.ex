defmodule QRCode.Mode do
  @moduledoc """
  Mode selector.
  """

  alias QRCode.QR
  import QRCode.QR, only: [mode: 1]

  @spec select(QR.t(), QR.mode()) :: QR.t()
  def select(qr, mode) when mode(mode) do
    qr
    |> put_mode(mode)
    |> put_version()
  end

  defp put_mode(qr, mode) do
    %{qr | mode: mode}
  end

  defp put_version(%QR{mode: mode} = qr) do
    mode
    |> get_module()
    |> call(qr)
  end

  defp get_module(:byte) do
    QRCode.Mode.Byte
  end

  defp call(module, qr) do
    apply(module, :put_version, [qr])
  end
end
