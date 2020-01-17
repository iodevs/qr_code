defmodule QRCode.Png do
  @moduledoc """
  PNG serializer and helper functions.
  """

  alias MatrixReloaded.Matrix
  alias QRCode.{PngSettings, QR}

  @doc """
  Create Png image from QR matrix as binary.
  """
  @spec create(QR.t(), PngSettings.t()) :: binary()
  def create(%QR{matrix: matrix}, settings \\ %PngSettings{}) do
    create_png(matrix, settings)
  end

  @doc """
  Saves QR code to png file.  This function returns  [Result](https://hexdocs.pm/result/api-reference.html),
  it means either tuple of `{:ok, "path/to/file.png"}` or `{:error, reason}`.

  Also there are a few settings for png:
  ```elixir
        | Setting          | Type                | Default value | Description             |
        |------------------|---------------------|---------------|-------------------------|
        | scale            | positive integer    | 10            | scale for png QR code   |
        | margin           | positive integer    | 0             | margin for png QR code  |
        | background_color | string or {r, g, b} | "#ffffff"     | background color of png |
        | qrcode_color     | string or {r, g, b} | "#000000"     | color of QR code        |
  ```

  By this option, you can set the background of QR code, QR code colors or size QR code.
  Let's see an example below:

      iex> settings = %QRCode.PngSettings{qrcode_color: {17, 170, 136}}
      iex> qr = QRCode.QR.create("your_string")
      iex> qr |> Result.and_then(&QRCode.Png.save_as(&1,"/tmp/your_name.png", settings))
      {:ok, "/tmp/your_name.png"}
  The png file will be saved into your tmp directory.

  ![QR code color](docs/qrcode_color.png)
  """
  @spec save_as(QR.t(), Path.t(), PngSettings.t()) ::
          Result.t(String.t() | File.posix() | :badarg | :terminated, Path.t())
  def save_as(%QR{matrix: matrix}, png_name, settings \\ %PngSettings{}) do
    matrix
    |> create_png(settings)
    |> save(png_name)
  end

  @doc """
  Create Png image from QR matrix as binary and encode it into a base 64.
  This encoded string can be then used in Html as

  `<img src="data:image/png+xml; base64, encoded_png_qr_code" />`
  """
  @spec to_base64(QR.t(), PngSettings.t()) :: binary()
  def to_base64(%QR{matrix: matrix}, settings \\ %PngSettings{}) do
    matrix
    |> create_png(settings)
    |> Base.encode64()
  end

  @white 0
  @black 1

  defp create_png(matrix, %PngSettings{
         scale: scale,
         margin: margin,
         background_color: background_color,
         qrcode_color: qrcode_color
       }) do
    {rank_matrix, _} = Matrix.size(matrix)
    width = rank_matrix * scale + 2 * margin
    height = rank_matrix * scale + 2 * margin
    {:ok, storage} = start_storage()

    png_options = %{
      size: {width, height},
      mode: {:indexed, 8},
      palette: {:rgb, 8, [to_rgb(background_color), to_rgb(qrcode_color)]},
      call: &save_chunk(storage, &1)
    }

    white = Enum.map(1..scale, fn _ -> @white end)
    black = Enum.map(1..scale, fn _ -> @black end)

    code_to_color = fn x ->
      case x do
        1 -> black
        0 -> white
      end
    end

    margin_row = map_seq(width, fn _ -> @white end)
    margin_pixels = map_seq(margin, fn _ -> @white end)

    png = :png.create(png_options)
    append_margin_row = fn _ -> :png.append(png, {:row, margin_row}) end

    _ = map_seq(margin, append_margin_row)

    Enum.each(matrix, fn row ->
      row_pixels = Enum.map(row, code_to_color)

      _ =
        map_seq(scale, fn _ ->
          :png.append(png, {:row, [margin_pixels, row_pixels, margin_pixels]})
        end)
    end)

    _ = map_seq(margin, append_margin_row)
    :png.close(png)
    release_storage(storage)
  end

  defp save(png, png_name) do
    png_name
    |> File.open([:write])
    |> Result.and_then(&write(&1, png))
    |> Result.and_then(&close(&1, png_name))
  end

  defp write(file, png) do
    case IO.binwrite(file, png) do
      :ok -> {:ok, file}
      err -> err
    end
  end

  defp close(file, png_name) do
    case File.close(file) do
      :ok -> {:ok, png_name}
      err -> err
    end
  end

  # Helpers

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

  defp map_seq(size, callback) do
    if size > 0, do: Enum.map(1..size, fn x -> callback.(x) end), else: []
  end

  defp start_storage, do: Agent.start_link(fn -> [] end)

  defp save_chunk(storage, iodata) do
    Agent.update(storage, fn acc -> [acc, iodata] end)
  end

  defp release_storage(storage) do
    iodata = Agent.get(storage, & &1)
    :ok = Agent.stop(storage)
    IO.iodata_to_binary(iodata)
  end
end
