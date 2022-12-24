defmodule QRCode.Render.Svg do
  @moduledoc """
  Create SVG structure with settings.
  """

  alias MatrixReloaded.Matrix
  alias QRCode.QR
  alias QRCode.Render.SvgSettings

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

  @doc """
  Create Svg structure from QR matrix as binary. This binary contains svg
  attributes and svg elements.
  """
  @spec create(Result.t(String.t(), QR.t()), SvgSettings.t()) :: Result.t(String.t(), binary())
  def create(qr, settings \\ %SvgSettings{})

  def create({:ok, %QR{matrix: matrix}}, settings) do
    matrix
    |> create_svg(settings)
    |> Result.ok()
  end

  def create(error, _settings), do: error

  # Private

  defp create_svg(matrix, settings) do
    matrix
    |> construct_body(%__MODULE__{}, settings)
    |> construct_svg(settings)
  end

  defp construct_body(matrix, svg, %SvgSettings{scale: scale}) do
    {rank_matrix, _} = Matrix.size(matrix)

    %{
      svg
      | body:
          matrix
          |> find_nonzero_element()
          |> Enum.map(&create_rect(&1, scale)),
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
         %SvgSettings{
           background_opacity: bg_tr,
           background_color: bg,
           image: image,
           qrcode_color: qc,
           scale: scale,
           structure: structure
         }
       ) do
    {:svg,
     %{
       xmlns: xmlns,
       xlink: xlink,
       width: rank_matrix * scale,
       height: rank_matrix * scale
     }, [background_rect(bg, bg_tr), to_group(body, qc), put_image(image)]}
    |> XmlBuilder.generate(format: format(structure))
  end

  # Helpers

  defp background_settings(color) do
    %{
      width: "100%",
      height: "100%",
      fill: to_hex(color)
    }
  end

  defp create_rect({x_pos, y_pos}, scale) do
    {:rect, %{width: scale, height: scale, x: scale * x_pos, y: scale * y_pos}, nil}
  end

  defp background_rect(color, nil) do
    {:rect, background_settings(color), nil}
  end

  defp background_rect(color, opacity)
       when 0.0 <= opacity and opacity <= 1.0 do
    bg_settings =
      color
      |> background_settings()
      |> Map.put(:"fill-opacity", opacity)

    {:rect, bg_settings, nil}
  end

  defp to_group(body, color) do
    {:g, %{fill: to_hex(color)}, body}
  end

  defp put_image(nil), do: ""

  defp put_image({path_to_image, size}) when is_binary(path_to_image) and 0 < size do
    {:image,
     %{
       href: Path.basename(path_to_image),
       height: size,
       width: size,
       x: "50%",
       y: "50%",
       transform: "translate(-#{size / 2}, -#{size / 2})"
     }, nil}
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

  defp format(:minify), do: :none
  defp format(:readable), do: :indent

  defp to_hex({r, g, b} = color) when is_tuple(color) do
    "##{encode_color(r)}#{encode_color(g)}#{encode_color(b)}"
  end

  defp to_hex(color) do
    color
  end

  def encode_color(c) when is_integer(c) and 0 <= c and c <= 255 do
    c |> :binary.encode_unsigned() |> Base.encode16()
  end
end
