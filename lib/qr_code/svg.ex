defmodule QRCode.Svg do
  @moduledoc """
  SVG structure and helper functions.
  """

  alias MatrixReloaded.Matrix

  @type svg_string :: String.t()
  @type background_color :: String.t() | tuple
  @type qrcode_color :: String.t() | tuple

  @type t :: %__MODULE__{
          scale: integer,
          background_color: background_color,
          qrcode_color: qrcode_color
        }

  defstruct scale: 10,
            background_color: "#ffffff",
            qrcode_color: "#000000"

  @spec generate(Matrix.t(), svg_string(), t()) ::
          :ok | Result.Error.t(File.posix() | :badarg | :terminated | String.t())
  def generate(matrix, svg_name \\ "tmp/qr_code.svg", settings \\ %__MODULE__{}) do
    matrix
    |> create(settings)
    |> save(svg_name)
  end

  defp create(matrix, %__MODULE__{background_color: bg, qrcode_color: qc, scale: scale}) do
    {row_size, col_size} = Matrix.size(matrix)

    body =
      matrix
      |> find_nonzero_element()
      |> Enum.map(&create_rect(&1, scale, qc))

    {:svg,
     %{
       xmlns: "http://www.w3.org/2000/svg",
       xlink: "http://www.w3.org/1999/xlink",
       width: row_size * scale,
       height: col_size * scale
     }, [background_rect(bg) | body]}
    |> XmlBuilder.generate()
  end

  defp save(svg, svg_name) do
    svg_name
    |> File.open([:write], fn file ->
      IO.binwrite(file, svg)
    end)
  end

  defp create_rect({x_pos, y_pos}, scale, color) do
    {:rect,
     %{width: scale, height: scale, x: scale * x_pos, y: scale * y_pos, fill: to_hex(color)}, nil}
  end

  defp background_rect(color) do
    {:rect, %{width: "100%", height: "100%", fill: to_hex(color)}, nil}
  end

  defp find_nonzero_element(matrix) do
    matrix
    |> Enum.with_index()
    |> Enum.map(fn {row, i} ->
      row
      |> Enum.with_index()
      |> Enum.reduce([], fn
        {nil, _}, acc -> acc
        {0, _}, acc -> acc
        {1, j}, acc -> [{j, i} | acc]
      end)
    end)
    |> List.flatten()
  end

  defp to_hex(color) when is_tuple(color) do
    {r, g, b} = color

    "#" <>
      (r |> :binary.encode_unsigned() |> Base.encode16()) <>
      (g |> :binary.encode_unsigned() |> Base.encode16()) <>
      (b |> :binary.encode_unsigned() |> Base.encode16())
  end

  defp to_hex(color) do
    color
  end
end
