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

  @doc """
  Create Svg structure from QR matrix as binary. This binary contains svg
  attributes and svg elements.
  """
  @spec create(QR.t(), SvgSettings.t()) :: binary()
  def create(%QR{matrix: matrix}, settings \\ %SvgSettings{}) do
    create_svg(matrix, settings)
  end

  @doc """
  Saves QR code to svg file.  This function returns  [Result](https://hexdocs.pm/result/api-reference.html),
  it means either tuple of `{:ok, "path/to/file.svg"}` or `{:error, reason}`.

  Also there are a few settings for svg:
  ```elixir
        | Setting          | Type                | Default value | Description             |
        |------------------|---------------------|---------------|-------------------------|
        | scale            | positive integer    | 10            | scale for svg QR code   |
        | background_color | string or {r, g, b} | "#ffffff"     | background color of svg |
        | qrcode_color     | string or {r, g, b} | "#000000"     | color of QR code        |
        | format           | :none or :indent    | :none         | indentation of elements |
  ```

  By this option, you can set the background of QR code, QR code colors or size QR code. The
  format option is for removing indentation (of elements) in a svg file.
  Let's see an example below:

      iex> settings = %QRCode.SvgSettings{qrcode_color: {17, 170, 136}}
      iex> qr = QRCode.QR.create("your_string")
      iex> qr |> Result.and_then(&QRCode.Svg.save_as(&1,"/tmp/your_name.svg", settings))
      {:ok, "/tmp/your_name.svg"}
  The svg file will be saved into your tmp directory.

  ![QR code color](docs/qrcode_color.png)
  """
  @spec save_as(QR.t(), Path.t(), SvgSettings.t()) ::
          Result.t(String.t() | File.posix() | :badarg | :terminated, Path.t())
  def save_as(%QR{matrix: matrix}, svg_name, settings \\ %SvgSettings{}) do
    matrix
    |> create_svg(settings)
    |> save(svg_name)
  end

  @doc """
  Create Svg structure from QR matrix as binary and encode it into a base 64.
  This encoded string can be then used in Html as

  `<img src="data:image/svg+xml; base64, encoded_svg_qr_code" />`
  """
  @spec to_base64(QR.t(), SvgSettings.t()) :: binary()
  def to_base64(%QR{matrix: matrix}, settings \\ %SvgSettings{}) do
    matrix
    |> create_svg(settings)
    |> Base.encode64()
  end

  defp create_svg(matrix, settings) do
    matrix
    |> construct_body(%__MODULE__{}, settings)
    |> construct_svg(settings)
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
         %SvgSettings{background_color: bg, scale: scale, format: format}
       ) do
    {:svg,
     %{
       xmlns: xmlns,
       xlink: xlink,
       width: rank_matrix * scale,
       height: rank_matrix * scale
     }, [background_rect(bg) | body]}
    |> XmlBuilder.generate(format: format)
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
