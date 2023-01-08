defmodule QRCode.Mode do
  @moduledoc """
  Mode selector.
  """

  alias QRCode.QR
  import QRCode.QR, only: [mode: 1]

  @spec select(QR.t(), QR.mode()) :: Result.t(String.t(), QR.t())
  def select(qr, mode) when mode(mode) do
    qr
    |> put_mode(mode)
    |> put_version()
  end

  defp put_mode(qr, mode) do
    %{qr | mode: mode}
  end

  defp get_module(:byte) do
    QRCode.Mode.Byte
  end

  defp get_module(:alphanumeric) do
    QRCode.Mode.Alphanumeric
  end

  defp call(module, level) do
    apply(module, :level, [level])
  end

  # @spec put_version(QR.t()) :: Result.t(String.t(), QR.t())
  defp put_version(%QR{orig: orig} = qr) do
    qr
    |> get_character_capacities_for_level()
    |> find_version(byte_size(orig))
    |> Result.map(fn ver -> %{qr | version: ver} end)
  end

  defp get_character_capacities_for_level(%QR{ecc_level: level, mode: mode}) do
    mode
    |> get_module()
    |> call(level)
  end

  defp find_version(level, chars) do
    Enum.reduce_while(level, {:error, "Input string can't be encoded"}, fn {max, ver}, acc ->
      if chars <= max do
        {:halt, {:ok, ver}}
      else
        {:cont, acc}
      end
    end)
  end
end
