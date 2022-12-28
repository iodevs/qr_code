defmodule QRCode.Render.Png do
  @moduledoc """
  Create PNG image with settings.
  """

  alias MatrixReloaded.Matrix
  alias QRCode.QR
  alias QRCode.Render.PngSettings

  @doc """
  Create Png image from QR matrix as binary.
  """
  @spec create(Result.t(String.t(), QR.t()), PngSettings.t()) :: Result.t(String.t(), binary())
  def create({:ok, %QR{matrix: matrix}}, settings) do
    matrix
    |> create_png(settings)
    |> Result.ok()
  end

  def create(error, _settings), do: error

  # Private

  defp create_png(
         matrix,
         %PngSettings{
           scale: scale,
           background_color: background_color,
           qrcode_color: qrcode_color
         }
       ) do
    {rows, cols} = Matrix.size(matrix)
    height = rows * scale
    width = cols * scale

    bitmap =
      matrix
      |> rescale_rows(scale)
      |> List.flatten()
      |> rescale_cols_and_put_colors(scale, to_rgb(background_color), to_rgb(qrcode_color))
      |> List.flatten()

    Pngex.new()
    |> Pngex.set_type(:rgb)
    |> Pngex.set_depth(:depth8)
    |> Pngex.set_size(width, height)
    |> Pngex.generate(bitmap)
    |> IO.iodata_to_binary()
  end

  defp rescale_rows(matrix, scale) do
    Enum.map(matrix, fn row -> List.duplicate(row, scale) end)
  end

  defp rescale_cols_and_put_colors(bin, scale, background_color, qrcode_color) do
    Enum.map(bin, fn
      1 -> List.duplicate(qrcode_color, scale)
      0 -> List.duplicate(background_color, scale)
    end)
  end

  defp to_rgb(color) when is_tuple(color) do
    color
  end

  defp to_rgb("#" <> <<r::binary-size(2), g::binary-size(2), b::binary-size(2)>>) do
    {decode_color(r), decode_color(g), decode_color(b)}
  end

  defp decode_color(c) do
    Base.decode16!(c, case: :mixed)
    |> :binary.decode_unsigned()
  end
end
