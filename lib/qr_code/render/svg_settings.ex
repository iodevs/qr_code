defmodule QRCode.Render.SvgSettings do
  @moduledoc """
  Settings structure for Svg.
  """

  @type image_file_path :: binary()
  @type base64_encoded_image_binary :: binary()
  @type mime_type_atom :: :svg | :png | :jpg | :jpeg
  @type image_size :: pos_integer()

  @type image ::
          ExMaybe.t(
            {image_file_path(), image_size()}
            | {base64_encoded_image_binary(), mime_type_atom(), image_size()}
          )

  @type background_opacity :: ExMaybe.t(float())
  @type background_color :: String.t() | tuple
  @type qrcode_color :: String.t() | tuple
  @type flatten :: boolean()
  @type structure :: :minify | :readable

  @type t :: %__MODULE__{
          scale: integer,
          image: image,
          background_opacity: background_opacity,
          background_color: background_color,
          qrcode_color: qrcode_color,
          flatten: flatten,
          structure: structure
        }

  defstruct scale: 10,
            image: nil,
            background_opacity: nil,
            background_color: "#ffffff",
            qrcode_color: "#000000",
            flatten: false,
            structure: :minify
end
