defmodule QRCode.SvgSettings do
  @moduledoc """
  Settings structure for Svg.
  """

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
end
