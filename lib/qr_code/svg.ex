defmodule QRCode.Svg do
  @moduledoc """
  SVG structure and helper functions.
  """

  alias MatrixReloaded.Matrix
  alias QRCode.{QR, SvgSettings}

  @type t :: %__MODULE__{
          xmlns: String.t(),
          xlink: String.t(),
          width: ExMaybe.t(integer),
          height: ExMaybe.t(integer),
          body: String.t(),
          rank_matrix: ExMaybe.t(pos_integer)
        }

  defstruct xmlns: "http://www.w3.org/2000/svg",
            xlink: "http://www.w3.org/1999/xlink",
            width: nil,
            height: nil,
            body: nil,
            rank_matrix: nil

  @spec save_as(QR.t(), Path.t(), SvgSettings.t()) ::
          Result.t(String.t() | File.posix() | :badarg | :terminated, Path.t())
  def save_as(%QR{matrix: matrix}, svg_name, settings \\ %SvgSettings{}) do
    matrix
    |> construct_body(%__MODULE__{}, settings)
    |> construct_svg(settings)
    |> save(svg_name)
  end

  defp construct_body(matrix, svg, %SvgSettings{qrcode_color: qc, scale: scale}) do
    {rank_matrix, _} = Matrix.size(matrix)

    %{
      svg
      | body:
          matrix
          |> find_nonzero_element()
          |> Enum.map(&create_rect(&1, scale, qc)),
        rank_matrix: rank_matrix
    }
  end

  defp construct_svg(
         %__MODULE__{
           xmlns: xmlns,
           xlink: xlink,
           body: body,
           rank_matrix: rank_matrix
         },
         %SvgSettings{background_color: bg, scale: scale}
       ) do
    {:svg,
     %{
       xmlns: xmlns,
       xlink: xlink,
       width: rank_matrix * scale,
       height: rank_matrix * scale
     }, [background_rect(bg) | body]}
    |> XmlBuilder.generate()
  end

  defp save(svg, svg_name) do
    svg_name
    |> File.open([:write])
    |> Result.and_then(&write(&1, svg))
    |> Result.and_then(&close(&1, svg_name))
  end

  defp write(file, svg) do
    case IO.binwrite(file, svg) do
      :ok -> {:ok, file}
      err -> err
    end
  end

  defp close(file, svg_name) do
    case File.close(file) do
      :ok -> {:ok, svg_name}
      err -> err
    end
  end

  # Helpers

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
        {0, _}, acc -> acc
        {1, j}, acc -> [{i, j} | acc]
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
