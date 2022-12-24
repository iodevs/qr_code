defmodule QRCode do
  @moduledoc """
  QR code generator.
  """

  alias QRCode.Render.{PngSettings, SvgSettings}

  @doc """
  See `QRCode.QR.create/2`
  """
  defdelegate create(text, ecc_level \\ :low), to: QRCode.QR

  @doc """
  See `QRCode.QR.create!/2`
  """
  defdelegate create!(text, ecc_level \\ :low), to: QRCode.QR

  @doc """
  See `QRCode.Render.Svg/3`
  """
  defdelegate render(qr, :svg, svg_settings // %SvgSettings{}),
    to: QRCode.Render.Svg

  @doc """
  See `QRCode.Render.Png/3`
  """
  defdelegate render(qr, :png, png_settings // %PngSettings{}),
    to: QRCode.Render.Png


  @spec to_base64(Result.t(binary(), t())) :: Result.t(binary(), t())
  def to_base64({:ok, rendered_qr_matrix}) do
    rendered_qr_matrix
    |> Base.encode64()
    |> Result.ok()
  end

  def to_base64(error), do: error

  @spec save(Result.t(binary(), t()), Path.t()) ::
      Result.t(String.t() | File.posix() | :badarg | :terminated, Path.t())
  def save({:ok, rendered_qr_matrix}, path_with_file_name) do
    path_with_file_name
      |> File.open([:write])
      |> Result.and_then(&write(&1, rendered_qr_matrix))
      |> Result.and_then(&close(&1, path_with_file_name))
  end

  def save(error, _path_with_file_name), do: error

  defp write(file, data) do
    case IO.binwrite(file, data) do
      :ok -> {:ok, file}
      err -> err
    end
  end

  defp close(file, file_name) do
    case File.close(file) do
      :ok -> {:ok, file_name}
      err -> err
    end
  end

end
