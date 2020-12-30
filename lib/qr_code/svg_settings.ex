defmodule QRCode.SvgSettings do
  @moduledoc """
  Settings structure for Svg.
  """

  @type background_transparency :: ExMaybe.t(float())
  @type background_color :: String.t() | tuple
  @type qrcode_color :: String.t() | tuple
  @type format :: :none | :indent

  @type t :: %__MODULE__{
          scale: integer,
          background_transparency: background_transparency,
          background_color: background_color,
          qrcode_color: qrcode_color,
          format: format
        }

  defstruct scale: 10,
            background_transparency: nil,
            background_color: "#ffffff",
            qrcode_color: "#000000",
            format: :none
end
