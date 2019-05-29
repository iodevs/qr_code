defmodule QRCode.Message do
  @moduledoc """
  A message interleaving module.
  """
  alias QRCode.QR
  alias QRCode.ErrorCorrection, as: ECC

  import QRCode.QR, only: [version: 1]

  @remainder_bits %{
    1 => 0,
    2 => 7,
    3 => 7,
    4 => 7,
    5 => 7,
    6 => 7,
    7 => 0,
    8 => 0,
    9 => 0,
    10 => 0,
    11 => 0,
    12 => 0,
    13 => 0,
    14 => 3,
    15 => 3,
    16 => 3,
    17 => 3,
    18 => 3,
    19 => 3,
    20 => 3,
    21 => 4,
    22 => 4,
    23 => 4,
    24 => 4,
    25 => 4,
    26 => 4,
    27 => 4,
    28 => 3,
    29 => 3,
    30 => 3,
    31 => 3,
    32 => 3,
    33 => 3,
    34 => 3,
    35 => 0,
    36 => 0,
    37 => 0,
    38 => 0,
    39 => 0,
    40 => 0
  }

  @spec put(QR.t()) :: QR.t()
  def put(%QR{version: version, ecc: %ECC{groups: {g1, g2}, codewords: {c1, c2}}} = qr) do
    %QR{
      qr
      | message:
          c1
          |> Enum.concat(c2)
          |> flatten(flatten(g1 ++ g2))
          |> Enum.reverse()
          |> to_bitstring()
          |> add_remainder(version)
    }
  end

  defp add_remainder(msg, v) when version(v) and is_bitstring(msg) do
    case @remainder_bits[v] do
      0 -> msg
      bits -> <<msg::bitstring, 0::size(bits)>>
    end
  end

  defp flatten(list, acc \\ [])
  defp flatten([], acc), do: acc

  defp flatten(list, acc) do
    {acc, list} =
      Enum.reduce(list, {acc, []}, fn
        [h | t], {flat, rest} -> {[h | flat], [t | rest]}
        [], acc -> acc
      end)

    list
    |> Enum.reverse()
    |> flatten(acc)
  end

  defp to_bitstring(list, acc \\ <<>>)
  defp to_bitstring([], acc), do: acc

  defp to_bitstring([h | t], acc) do
    to_bitstring(t, <<acc::bitstring, h::size(8)>>)
  end
end
