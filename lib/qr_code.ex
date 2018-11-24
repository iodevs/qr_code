defmodule QRCode do
end

# <<0b0010::4, 11:9>>
# <<x::4, y::9>> <<0b0010, 11:9>>

# str = "čáp"
# <<h::8, rest::binary>> = str

# č - <<192, 141>>
# á - <<195, 161>>
# p - <<112>>

# Encoded Data
# <<192, 141, 195, 161, 112>>
