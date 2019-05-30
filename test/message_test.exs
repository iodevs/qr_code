defmodule MessageTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use PropCheck
  doctest QRCode.Message

  alias QRCode.{QR, Message}
  alias QRCode.ErrorCorrection, as: ECC

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

  @ecc_table %{
    1 => %{
      low: {7, 1, 19, 0, 0},
      medium: {10, 1, 16, 0, 0},
      quartile: {13, 1, 13, 0, 0},
      high: {17, 1, 9, 0, 0}
    },
    2 => %{
      low: {10, 1, 34, 0, 0},
      medium: {16, 1, 28, 0, 0},
      quartile: {22, 1, 22, 0, 0},
      high: {28, 1, 16, 0, 0}
    },
    3 => %{
      low: {15, 1, 55, 0, 0},
      medium: {26, 1, 44, 0, 0},
      quartile: {18, 2, 17, 0, 0},
      high: {22, 2, 13, 0, 0}
    },
    4 => %{
      low: {20, 1, 80, 0, 0},
      medium: {18, 2, 32, 0, 0},
      quartile: {26, 2, 24, 0, 0},
      high: {16, 4, 9, 0, 0}
    },
    5 => %{
      low: {26, 1, 108, 0, 0},
      medium: {24, 2, 43, 0, 0},
      quartile: {18, 2, 15, 2, 16},
      high: {22, 2, 11, 2, 12}
    },
    6 => %{
      low: {18, 2, 68, 0, 0},
      medium: {16, 4, 27, 0, 0},
      quartile: {24, 4, 19, 0, 0},
      high: {28, 4, 15, 0, 0}
    },
    7 => %{
      low: {20, 2, 78, 0, 0},
      medium: {18, 4, 31, 0, 0},
      quartile: {18, 2, 14, 4, 15},
      high: {26, 4, 13, 1, 14}
    },
    8 => %{
      low: {24, 2, 97, 0, 0},
      medium: {22, 2, 38, 2, 39},
      quartile: {22, 4, 18, 2, 19},
      high: {26, 4, 14, 2, 15}
    },
    9 => %{
      low: {30, 2, 116, 0, 0},
      medium: {22, 3, 36, 2, 37},
      quartile: {20, 4, 16, 4, 17},
      high: {24, 4, 12, 4, 13}
    },
    10 => %{
      low: {18, 2, 68, 2, 69},
      medium: {26, 4, 43, 1, 44},
      quartile: {24, 6, 19, 2, 20},
      high: {28, 6, 15, 2, 16}
    },
    11 => %{
      low: {20, 4, 81, 0, 0},
      medium: {30, 1, 50, 4, 51},
      quartile: {28, 4, 22, 4, 23},
      high: {24, 3, 12, 8, 13}
    },
    12 => %{
      low: {24, 2, 92, 2, 93},
      medium: {22, 6, 36, 2, 37},
      quartile: {26, 4, 20, 6, 21},
      high: {28, 7, 14, 4, 15}
    },
    13 => %{
      low: {26, 4, 107, 0, 0},
      medium: {22, 8, 37, 1, 38},
      quartile: {24, 8, 20, 4, 21},
      high: {22, 12, 11, 4, 12}
    },
    14 => %{
      low: {30, 3, 115, 1, 116},
      medium: {24, 4, 40, 5, 41},
      quartile: {20, 11, 16, 5, 17},
      high: {24, 11, 12, 5, 13}
    },
    15 => %{
      low: {22, 5, 87, 1, 88},
      medium: {24, 5, 41, 5, 42},
      quartile: {30, 5, 24, 7, 25},
      high: {24, 11, 12, 7, 13}
    },
    16 => %{
      low: {24, 5, 98, 1, 99},
      medium: {28, 7, 45, 3, 46},
      quartile: {24, 15, 19, 2, 20},
      high: {30, 3, 15, 13, 16}
    },
    17 => %{
      low: {28, 1, 107, 5, 108},
      medium: {28, 10, 46, 1, 47},
      quartile: {28, 1, 22, 15, 23},
      high: {28, 2, 14, 17, 15}
    },
    18 => %{
      low: {30, 5, 120, 1, 121},
      medium: {26, 9, 43, 4, 44},
      quartile: {28, 17, 22, 1, 23},
      high: {28, 2, 14, 19, 15}
    },
    19 => %{
      low: {28, 3, 113, 4, 114},
      medium: {26, 3, 44, 11, 45},
      quartile: {26, 17, 21, 4, 22},
      high: {26, 9, 13, 16, 14}
    },
    20 => %{
      low: {28, 3, 107, 5, 108},
      medium: {26, 3, 41, 13, 42},
      quartile: {30, 15, 24, 5, 25},
      high: {28, 15, 15, 10, 16}
    },
    21 => %{
      low: {28, 4, 116, 4, 117},
      medium: {26, 17, 42, 0, 0},
      quartile: {28, 17, 22, 6, 23},
      high: {30, 19, 16, 6, 17}
    },
    22 => %{
      low: {28, 2, 111, 7, 112},
      medium: {28, 17, 46, 0, 0},
      quartile: {30, 7, 24, 16, 25},
      high: {24, 34, 13, 0, 0}
    },
    23 => %{
      low: {30, 4, 121, 5, 122},
      medium: {28, 4, 47, 14, 48},
      quartile: {30, 11, 24, 14, 25},
      high: {30, 16, 15, 14, 16}
    },
    24 => %{
      low: {30, 6, 117, 4, 118},
      medium: {28, 6, 45, 14, 46},
      quartile: {30, 11, 24, 16, 25},
      high: {30, 30, 16, 2, 17}
    },
    25 => %{
      low: {26, 8, 106, 4, 107},
      medium: {28, 8, 47, 13, 48},
      quartile: {30, 7, 24, 22, 25},
      high: {30, 22, 15, 13, 16}
    },
    26 => %{
      low: {28, 10, 114, 2, 115},
      medium: {28, 19, 46, 4, 47},
      quartile: {28, 28, 22, 6, 23},
      high: {30, 33, 16, 4, 17}
    },
    27 => %{
      low: {30, 8, 122, 4, 123},
      medium: {28, 22, 45, 3, 46},
      quartile: {30, 8, 23, 26, 24},
      high: {30, 12, 15, 28, 16}
    },
    28 => %{
      low: {30, 3, 117, 10, 118},
      medium: {28, 3, 45, 23, 46},
      quartile: {30, 4, 24, 31, 25},
      high: {30, 11, 15, 31, 16}
    },
    29 => %{
      low: {30, 7, 116, 7, 117},
      medium: {28, 21, 45, 7, 46},
      quartile: {30, 1, 23, 37, 24},
      high: {30, 19, 15, 26, 16}
    },
    30 => %{
      low: {30, 5, 115, 10, 116},
      medium: {28, 19, 47, 10, 48},
      quartile: {30, 15, 24, 25, 25},
      high: {30, 23, 15, 25, 16}
    },
    31 => %{
      low: {30, 13, 115, 3, 116},
      medium: {28, 2, 46, 29, 47},
      quartile: {30, 42, 24, 1, 25},
      high: {30, 23, 15, 28, 16}
    },
    32 => %{
      low: {30, 17, 115, 0, 0},
      medium: {28, 10, 46, 23, 47},
      quartile: {30, 10, 24, 35, 25},
      high: {30, 19, 15, 35, 16}
    },
    33 => %{
      low: {30, 17, 115, 1, 116},
      medium: {28, 14, 46, 21, 47},
      quartile: {30, 29, 24, 19, 25},
      high: {30, 11, 15, 46, 16}
    },
    34 => %{
      low: {30, 13, 115, 6, 116},
      medium: {28, 14, 46, 23, 47},
      quartile: {30, 44, 24, 7, 25},
      high: {30, 59, 16, 1, 17}
    },
    35 => %{
      low: {30, 12, 121, 7, 122},
      medium: {28, 12, 47, 26, 48},
      quartile: {30, 39, 24, 14, 25},
      high: {30, 22, 15, 41, 16}
    },
    36 => %{
      low: {30, 6, 121, 14, 122},
      medium: {28, 6, 47, 34, 48},
      quartile: {30, 46, 24, 10, 25},
      high: {30, 2, 15, 64, 16}
    },
    37 => %{
      low: {30, 17, 122, 4, 123},
      medium: {28, 29, 46, 14, 47},
      quartile: {30, 49, 24, 10, 25},
      high: {30, 24, 15, 46, 16}
    },
    38 => %{
      low: {30, 4, 122, 18, 123},
      medium: {28, 13, 46, 32, 47},
      quartile: {30, 48, 24, 14, 25},
      high: {30, 42, 15, 32, 16}
    },
    39 => %{
      low: {30, 20, 117, 4, 118},
      medium: {28, 40, 47, 7, 48},
      quartile: {30, 43, 24, 22, 25},
      high: {30, 10, 15, 67, 16}
    },
    40 => %{
      low: {30, 19, 118, 6, 119},
      medium: {28, 18, 47, 31, 48},
      quartile: {30, 34, 24, 34, 25},
      high: {30, 20, 15, 61, 16}
    }
  }

  test "should generate the right message" do
    qr = %QR{
      ecc_level: :quartile,
      version: 5,
      ecc: %ECC{
        ec_codewrods_per_block: 18,
        blocks_in_group1: 2,
        codewords_per_block_in_group1: 15,
        blocks_in_group2: 2,
        codewords_per_block_in_group2: 16,
        groups: {
          [
            [67, 85, 70, 134, 87, 38, 85, 194, 119, 50, 6, 18, 6, 103, 38],
            [246, 246, 66, 7, 118, 134, 242, 7, 38, 86, 22, 198, 199, 146, 6]
          ],
          [
            [182, 230, 247, 119, 50, 7, 118, 134, 87, 38, 82, 6, 134, 151, 50, 7],
            [70, 247, 118, 86, 194, 6, 151, 50, 16, 236, 17, 236, 17, 236, 17, 236]
          ]
        },
        codewords: {
          [
            [
              213,
              199,
              11,
              45,
              115,
              247,
              241,
              223,
              229,
              248,
              154,
              117,
              154,
              111,
              86,
              161,
              111,
              39
            ],
            [87, 204, 96, 60, 202, 182, 124, 157, 200, 134, 27, 129, 209, 17, 163, 163, 120, 133]
          ],
          [
            [
              148,
              116,
              177,
              212,
              76,
              133,
              75,
              242,
              238,
              76,
              195,
              230,
              189,
              10,
              108,
              240,
              192,
              141
            ],
            [235, 159, 5, 173, 24, 147, 59, 33, 106, 40, 255, 172, 82, 2, 131, 32, 178, 236]
          ]
        }
      }
    }

    expected =
      <<0b01000011111101101011011001000110010101011111011011100110111101110100011001000010111101110111011010000110000001110111011101010110010101110111011000110010110000100010011010000110000001110000011001010101111100100111011010010111110000100000011110000110001100100111011100100110010101110001000000110010010101100010011011101100000001100001011001010010000100010001001011000110000001101110110000000110110001111000011000010001011001111001001010010111111011000010011000000110001100100001000100000111111011001101010101010111100101001110101111000111110011000111010010011111000010110110000010110001000001010010110100111100110101001010110101110011110010100100110000011000111101111011011010000101100100111111000101111100010010110011101111011111100111011111001000100001111001011100100011101110011010101111100010000110010011000010100010011010000110111100001111111111011101011000000111100110101011001001101011010001101111010101001001101111000100010000101000000010010101101010001101101100100000111010000110100011111100000010000001101111011110001100000010110010001001111000010110001101111011000000000::size(
          1079
        )>>

    %QR{message: msg} = Message.put(qr)

    assert msg == expected
  end

  # Properties

  property "should right length" do
    forall qr <- qr() do
      qr = Message.put(qr)
      check_message_length(qr)
    end
  end

  property "should start with first codeword in first group and block" do
    forall qr <- qr() do
      qr = Message.put(qr)
      check_start_with(qr)
    end
  end

  # Helpers

  defp check_message_length(%QR{
         version: v,
         ecc: %ECC{
           ec_codewrods_per_block: eccpb,
           blocks_in_group1: bg1,
           blocks_in_group2: bg2,
           codewords_per_block_in_group1: cbg1,
           codewords_per_block_in_group2: cbg2
         },
         message: message
       }) do
    expectd_message_length =
      (eccpb * (bg1 + bg2) + bg1 * cbg1 + bg2 * cbg2) * 8 + @remainder_bits[v]

    bit_size(message) == expectd_message_length
  end

  defp check_start_with(%QR{
         ecc: %ECC{
           groups: {[[expected | _] | _], _}
         },
         message: <<first::size(8), _rest::bitstring>>
       }) do
    first == expected
  end

  # Generators
  defp level() do
    oneof([
      :low,
      :medium,
      :quartile,
      :high
    ])
  end

  defp codewords(blocks_in_group1, blocks_in_group2, codewords_per_block) do
    let cw <-
          {vector(blocks_in_group1, vector(codewords_per_block, byte())),
           vector(blocks_in_group2, vector(codewords_per_block, byte()))} do
      cw
    end
  end

  defp groups(blocks_in_group1, codewords_in_group1, blocks_in_group2, codewords_in_group2) do
    let groups <-
          {vector(blocks_in_group1, vector(codewords_in_group1, byte())),
           vector(blocks_in_group2, vector(codewords_in_group2, byte()))} do
      groups
    end
  end

  defp qr() do
    let {version, level} <- {range(1, 40), level()} do
      {ec_codewrods_per_block, blocks_in_group1, codewords_in_group1, blocks_in_group2,
       codewords_in_group2} = @ecc_table[version][level]

      let {codewords, groups} <-
            {codewords(blocks_in_group1, blocks_in_group2, ec_codewrods_per_block),
             groups(blocks_in_group1, codewords_in_group1, blocks_in_group2, codewords_in_group2)} do
        %QR{
          ecc_level: level,
          version: version,
          ecc: %ECC{
            ec_codewrods_per_block: ec_codewrods_per_block,
            blocks_in_group1: blocks_in_group1,
            codewords_per_block_in_group1: codewords_in_group1,
            blocks_in_group2: blocks_in_group2,
            codewords_per_block_in_group2: codewords_in_group2,
            groups: groups,
            codewords: codewords
          }
        }
      end
    end
  end
end
