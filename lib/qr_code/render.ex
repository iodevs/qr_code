defmodule QRCode.Render do
  @moduledoc """
  Render common module.
  """

  alias QRCode.Render.{PngSettings, SvgSettings}

  @doc """
  Render QR matrix to `svg` or `png` binary representation with default settings.
  """
  @spec render(Result.t(String.t(), binary()), :png | :svg) :: Result.t(String.t(), binary())
  def render(qr, :svg) do
    render(qr, :svg, %SvgSettings{})
  end

  def render(qr, :png) do
    render(qr, :png, %PngSettings{})
  end

  @doc """
  Render QR matrix to `svg` or `png` binary representation with your settings.

  You can change the appearance of `svg` using the options:
  ```elixir
  | Setting            | Type                   | Default value | Description                            |
  |--------------------|------------------------|---------------|----------------------------------------|
  | scale              | positive integer       | 10            | changes size of rendered QR code       |
  | image              | {string, size} or nil  | nil           | puts the image to the center of svg    |
  | background_opacity | nil or 0.0 <= x <= 1.0 | nil           | sets background opacity of svg         |
  | background_color   | string or {r, g, b}    | "#ffffff"     | sets background color of svg           |
  | qrcode_color       | string or {r, g, b}    | "#000000"     | sets color of QR                       |
  | structure          | :minify or :readable   | :minify       | minifies or makes readable of svg file |

  svg_settings = %QRCode.Render.SvgSettings{qrcode_color: {17, 170, 136}, structure: :readable}
  ```

  and same a way for `png`:

  ```elixir
  | Setting            | Type                   | Default value | Description                            |
  |--------------------|------------------------|---------------|----------------------------------------|
  | scale              | positive integer       | 10            | changes size of rendered QR            |
  | margin             | non-negative integer   | 0             | sets margin of for png QR code         |
  | background_color   | string or {r, g, b}    | "#ffffff"     | sets background color of png           |
  | qrcode_color       | string or {r, g, b}    | "#000000"     | sets color of QR                       |
  ```
  """
  @spec render(Result.t(String.t(), binary()), atom(), SvgSettings.t() | PngSettings.t()) ::
          Result.t(String.t(), binary())
  def render(qr, :svg, settings) do
    QRCode.Render.Svg.create(qr, settings)
  end

  def render(qr, :png, settings) do
    QRCode.Render.Png.create(qr, settings)
  end
end
