defmodule QRCode.Render.PngSettings do
  @moduledoc """
  Settings structure for Png.
  """

  @type background_color :: String.t() | tuple
  @type qrcode_color :: String.t() | tuple
  @type scale :: integer
  @type quiet_zone :: integer

  @type t :: %__MODULE__{
          scale: integer,
          background_color: background_color,
          qrcode_color: qrcode_color,
          quiet_zone: quiet_zone
        }

  defstruct scale: 10,
            background_color: "#ffffff",
            qrcode_color: "#000000",
            quiet_zone: 4
end
