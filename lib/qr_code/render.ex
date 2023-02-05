defmodule QRCode.Render do
  @moduledoc """
  Render common module.
  """

  @type image_format() :: :png | :svg

  alias QRCode.QR
  alias QRCode.Render.{PngSettings, SvgSettings}

  @doc """
  Render QR matrix to `svg` or `png` binary representation with default settings.
  """
  @spec render(QR.t(), image_format()) :: String.t()
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
  | Setting            | Type                   | Default value | Description                         |
  |--------------------|------------------------|---------------|-------------------------------------|
  | scale              | positive integer       | 10            | changes size of rendered QR code    |
  | background_opacity | nil or 0.0 <= x <= 1.0 | nil           | sets background opacity of svg      |
  | background_color   | string or {r, g, b}    | "#ffffff"     | sets background color of svg        |
  | qrcode_color       | string or {r, g, b}    | "#000000"     | sets color of QR                    |
  | image              | {string, size} or nil  | nil           | puts the image to the center of svg |
  | structure          | :minify or :readable   | :minify       | minifies or makes readable svg file |

  svg_settings = %QRCode.Render.SvgSettings{qrcode_color: {17, 170, 136}, structure: :readable}
  ```

  and same a way for `png`:

  ```elixir
  | Setting            | Type                   | Default value | Description                  |
  |--------------------|------------------------|---------------|------------------------------|
  | scale              | positive integer       | 10            | changes size of rendered QR  |
  | background_color   | string or {r, g, b}    | "#ffffff"     | sets background color of png |
  | qrcode_color       | string or {r, g, b}    | "#000000"     | sets color of QR             |
  ```
  """
  @spec render(QR.t(), image_format(), SvgSettings.t() | PngSettings.t()) :: String.t()
  def render(qr, :svg, settings) do
    QRCode.Render.Svg.create(qr, settings)
  end

  def render(qr, :png, settings) do
    QRCode.Render.Png.create(qr, settings)
  end

  @doc """
  Encodes rendered QR matrix as `svg` or `png` binary into a base 64.
  This encoded string can be then used in Html as

  For `svg` use
  ```
  <img src="data:image/svg+xml; base64, encoded_svg_qr_code" alt="QR code" />
  ```

  and in case of `png`
  ```
  <img src="data:image/png; base64, encoded_png_qr_code" alt="QR code" />
  ```
  """
  @spec to_base64(String.t()) :: String.t()
  def to_base64(rendered_qr_matrix) do
    Base.encode64(rendered_qr_matrix)
  end

  @doc """
  Saves rendered QR code to `svg` or `png` file. See a few examples below:

  ```elixir
    iex> "Hello World"
          |> QRCode.create(:high)
          |> QRCode.render(:svg)
          |> QRCode.save("/path/to/hello.svg")
    {:ok, "/path/to/hello.svg"}
  ```

  ```elixir
    iex> png_settings = %QRCode.Render.PngSettings{qrcode_color: {17, 170, 136}}
    iex> "Hello World"
          |> QRCode.create(:high)
          |> QRCode.render(:png, png_settings)
          |> QRCode.save("/tmp/to/hello.png")
    {:ok, "/path/to/hello.png"}
  ```
  ![QR code color](docs/qrcode_color.png)
  """
  @spec save(String.t(), Path.t()) :: {:ok, Path.t()} | {:error, File.posix()}
  def save(rendered_qr_matrix, path_with_file_name) do
    case File.write(path_with_file_name, rendered_qr_matrix) do
      :ok -> {:ok, path_with_file_name}
      err -> err
    end
  end
end
