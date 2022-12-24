defmodule QRCode.Render.SvgSettings do
  @moduledoc """
  Settings structure for Svg.
  """

  @type image :: ExMaybe.t({binary(), pos_integer()})
  @type background_opacity :: ExMaybe.t(float())
  @type background_color :: String.t() | tuple
  @type qrcode_color :: String.t() | tuple
  @type structure :: :minify | :readable

  @type t :: %__MODULE__{
          scale: integer,
          image: image,
          background_opacity: background_opacity,
          background_color: background_color,
          qrcode_color: qrcode_color,
          structure: structure
        }

  defstruct scale: 10,
            image: nil,
            background_opacity: nil,
            background_color: "#ffffff",
            qrcode_color: "#000000",
            structure: :minify
end
