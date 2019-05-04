defmodule QRCode.ErrorCorrection do
  @moduledoc """
  Error correction code words and block information.
  """

  alias QRCode.{QR, Polynom}
  alias QRCode.GeneratorPolynomial, as: GP
  import QRCode.QR, only: [level: 1, version: 1]

  @type groups() :: {[[], ...], [[]]}
  @type codewords() :: groups()
  @type t() :: %__MODULE__{
          ec_codewrods_per_block: ExMaybe.t(integer()),
          blocks_in_group1: ExMaybe.t(integer()),
          codewords_per_block_in_group1: ExMaybe.t(integer()),
          blocks_in_group2: ExMaybe.t(integer()),
          codewords_per_block_in_group2: ExMaybe.t(integer()),
          groups: ExMaybe.t(groups()),
          codewords: ExMaybe.t(codewords())
        }

  defstruct ec_codewrods_per_block: nil,
            blocks_in_group1: nil,
            codewords_per_block_in_group1: nil,
            blocks_in_group2: nil,
            codewords_per_block_in_group2: nil,
            groups: nil,
            codewords: nil

  @ecc_table [
    [
      low: {7, 1, 19, 0, 0},
      medium: {10, 1, 16, 0, 0},
      quartile: {13, 1, 13, 0, 0},
      high: {17, 1, 9, 0, 0}
    ],
    [
      low: {10, 1, 34, 0, 0},
      medium: {16, 1, 28, 0, 0},
      quartile: {22, 1, 22, 0, 0},
      high: {28, 1, 16, 0, 0}
    ],
    [
      low: {15, 1, 55, 0, 0},
      medium: {26, 1, 44, 0, 0},
      quartile: {18, 2, 17, 0, 0},
      high: {22, 2, 13, 0, 0}
    ],
    [
      low: {20, 1, 80, 0, 0},
      medium: {18, 2, 32, 0, 0},
      quartile: {26, 2, 24, 0, 0},
      high: {16, 4, 9, 0, 0}
    ],
    [
      low: {26, 1, 108, 0, 0},
      medium: {24, 2, 43, 0, 0},
      quartile: {18, 2, 15, 2, 16},
      high: {22, 2, 11, 2, 12}
    ],
    [
      low: {18, 2, 68, 0, 0},
      medium: {16, 4, 27, 0, 0},
      quartile: {24, 4, 19, 0, 0},
      high: {28, 4, 15, 0, 0}
    ],
    [
      low: {20, 2, 78, 0, 0},
      medium: {18, 4, 31, 0, 0},
      quartile: {18, 2, 14, 4, 15},
      high: {26, 4, 13, 1, 14}
    ],
    [
      low: {24, 2, 97, 0, 0},
      medium: {22, 2, 38, 2, 39},
      quartile: {22, 4, 18, 2, 19},
      high: {26, 4, 14, 2, 15}
    ],
    [
      low: {30, 2, 116, 0, 0},
      medium: {22, 3, 36, 2, 37},
      quartile: {20, 4, 16, 4, 17},
      high: {24, 4, 12, 4, 13}
    ],
    [
      low: {18, 2, 68, 2, 69},
      medium: {26, 4, 43, 1, 44},
      quartile: {24, 6, 19, 2, 20},
      high: {28, 6, 15, 2, 16}
    ],
    [
      low: {20, 4, 81, 0, 0},
      medium: {30, 1, 50, 4, 51},
      quartile: {28, 4, 22, 4, 23},
      high: {24, 3, 12, 8, 13}
    ],
    [
      low: {24, 2, 92, 2, 93},
      medium: {22, 6, 36, 2, 37},
      quartile: {26, 4, 20, 6, 21},
      high: {28, 7, 14, 4, 15}
    ],
    [
      low: {26, 4, 107, 0, 0},
      medium: {22, 8, 37, 1, 38},
      quartile: {24, 8, 20, 4, 21},
      high: {22, 12, 11, 4, 12}
    ],
    [
      low: {30, 3, 115, 1, 116},
      medium: {24, 4, 40, 5, 41},
      quartile: {20, 11, 16, 5, 17},
      high: {24, 11, 12, 5, 13}
    ],
    [
      low: {22, 5, 87, 1, 88},
      medium: {24, 5, 41, 5, 42},
      quartile: {30, 5, 24, 7, 25},
      high: {24, 11, 12, 7, 13}
    ],
    [
      low: {24, 5, 98, 1, 99},
      medium: {28, 7, 45, 3, 46},
      quartile: {24, 15, 19, 2, 20},
      high: {30, 3, 15, 13, 16}
    ],
    [
      low: {28, 1, 107, 5, 108},
      medium: {28, 10, 46, 1, 47},
      quartile: {28, 1, 22, 15, 23},
      high: {28, 2, 14, 17, 15}
    ],
    [
      low: {30, 5, 120, 1, 121},
      medium: {26, 9, 43, 4, 44},
      quartile: {28, 17, 22, 1, 23},
      high: {28, 2, 14, 19, 15}
    ],
    [
      low: {28, 3, 113, 4, 114},
      medium: {26, 3, 44, 11, 45},
      quartile: {26, 17, 21, 4, 22},
      high: {26, 9, 13, 16, 14}
    ],
    [
      low: {28, 3, 107, 5, 108},
      medium: {26, 3, 41, 13, 42},
      quartile: {30, 15, 24, 5, 25},
      high: {28, 15, 15, 10, 16}
    ],
    [
      low: {28, 4, 116, 4, 117},
      medium: {26, 17, 42, 0, 0},
      quartile: {28, 17, 22, 6, 23},
      high: {30, 19, 16, 6, 17}
    ],
    [
      low: {28, 2, 111, 7, 112},
      medium: {28, 17, 46, 0, 0},
      quartile: {30, 7, 24, 16, 25},
      high: {24, 34, 13, 0, 0}
    ],
    [
      low: {30, 4, 121, 5, 122},
      medium: {28, 4, 47, 14, 48},
      quartile: {30, 11, 24, 14, 25},
      high: {30, 16, 15, 14, 16}
    ],
    [
      low: {30, 6, 117, 4, 118},
      medium: {28, 6, 45, 14, 46},
      quartile: {30, 11, 24, 16, 25},
      high: {30, 30, 16, 2, 17}
    ],
    [
      low: {26, 8, 106, 4, 107},
      medium: {28, 8, 47, 13, 48},
      quartile: {30, 7, 24, 22, 25},
      high: {30, 22, 15, 13, 16}
    ],
    [
      low: {28, 10, 114, 2, 115},
      medium: {28, 19, 46, 4, 47},
      quartile: {28, 28, 22, 6, 23},
      high: {30, 33, 16, 4, 17}
    ],
    [
      low: {30, 8, 122, 4, 123},
      medium: {28, 22, 45, 3, 46},
      quartile: {30, 8, 23, 26, 24},
      high: {30, 12, 15, 28, 16}
    ],
    [
      low: {30, 3, 117, 10, 118},
      medium: {28, 3, 45, 23, 46},
      quartile: {30, 4, 24, 31, 25},
      high: {30, 11, 15, 31, 16}
    ],
    [
      low: {30, 7, 116, 7, 117},
      medium: {28, 21, 45, 7, 46},
      quartile: {30, 1, 23, 37, 24},
      high: {30, 19, 15, 26, 16}
    ],
    [
      low: {30, 5, 115, 10, 116},
      medium: {28, 19, 47, 10, 48},
      quartile: {30, 15, 24, 25, 25},
      high: {30, 23, 15, 25, 16}
    ],
    [
      low: {30, 13, 115, 3, 116},
      medium: {28, 2, 46, 29, 47},
      quartile: {30, 42, 24, 1, 25},
      high: {30, 23, 15, 28, 16}
    ],
    [
      low: {30, 17, 115, 0, 0},
      medium: {28, 10, 46, 23, 47},
      quartile: {30, 10, 24, 35, 25},
      high: {30, 19, 15, 35, 16}
    ],
    [
      low: {30, 17, 115, 1, 116},
      medium: {28, 14, 46, 21, 47},
      quartile: {30, 29, 24, 19, 25},
      high: {30, 11, 15, 46, 16}
    ],
    [
      low: {30, 13, 115, 6, 116},
      medium: {28, 14, 46, 23, 47},
      quartile: {30, 44, 24, 7, 25},
      high: {30, 59, 16, 1, 17}
    ],
    [
      low: {30, 12, 121, 7, 122},
      medium: {28, 12, 47, 26, 48},
      quartile: {30, 39, 24, 14, 25},
      high: {30, 22, 15, 41, 16}
    ],
    [
      low: {30, 6, 121, 14, 122},
      medium: {28, 6, 47, 34, 48},
      quartile: {30, 46, 24, 10, 25},
      high: {30, 2, 15, 64, 16}
    ],
    [
      low: {30, 17, 122, 4, 123},
      medium: {28, 29, 46, 14, 47},
      quartile: {30, 49, 24, 10, 25},
      high: {30, 24, 15, 46, 16}
    ],
    [
      low: {30, 4, 122, 18, 123},
      medium: {28, 13, 46, 32, 47},
      quartile: {30, 48, 24, 14, 25},
      high: {30, 42, 15, 32, 16}
    ],
    [
      low: {30, 20, 117, 4, 118},
      medium: {28, 40, 47, 7, 48},
      quartile: {30, 43, 24, 22, 25},
      high: {30, 10, 15, 67, 16}
    ],
    [
      low: {30, 19, 118, 6, 119},
      medium: {28, 18, 47, 31, 48},
      quartile: {30, 34, 24, 34, 25},
      high: {30, 20, 15, 61, 16}
    ]
  ]

  @spec total_data_codewords(QR.t()) :: integer()
  def total_data_codewords(%QR{version: version, ecc_level: level})
      when version(version) and level(level) do
    version
    |> get_ecc_row(level)
    |> compute_total_data_codewords()
  end

  @spec put(QR.t()) :: QR.t()
  def put(%QR{encoded: data, version: version, ecc_level: level} = qr)
      when version(version) and level(level) do
    %{
      qr
      | ecc:
          %__MODULE__{}
          |> put_info(version, level)
          |> put_groups(data)
          |> put_codewords()
    }
  end

  defp put_info(%__MODULE__{} = ecc, version, level) do
    {ec_codewrods_per_block, blocks_in_group1, codewords_in_group1, blocks_in_group2,
     codewords_in_group2} = get_ecc_row(version, level)

    %{
      ecc
      | ec_codewrods_per_block: ec_codewrods_per_block,
        blocks_in_group1: blocks_in_group1,
        codewords_per_block_in_group1: codewords_in_group1,
        blocks_in_group2: blocks_in_group2,
        codewords_per_block_in_group2: codewords_in_group2
    }
  end

  defp put_groups(%__MODULE__{} = ecc, data) do
    bytes_in_group1 = ecc.blocks_in_group1 * ecc.codewords_per_block_in_group1
    bytes_in_group2 = ecc.blocks_in_group2 * ecc.codewords_per_block_in_group2

    <<data_group1::binary-size(bytes_in_group1), data_group2::binary-size(bytes_in_group2)>> =
      data

    %{
      ecc
      | groups:
          {group(data_group1, ecc.blocks_in_group1, ecc.codewords_per_block_in_group1),
           group(data_group2, ecc.blocks_in_group2, ecc.codewords_per_block_in_group2)}
    }
  end

  defp put_codewords(%__MODULE__{groups: {g1, g2}, ec_codewrods_per_block: codewords} = ecc) do
    %{ecc | codewords: {compute_codewords(g1, codewords), compute_codewords(g2, codewords)}}
  end

  defp get_ecc_row(version, level) do
    @ecc_table
    |> Enum.at(version - 1)
    |> Keyword.get(level)
  end

  defp compute_codewords(group, codewords) do
    divisor = GP.create(codewords)

    Enum.map(group, &Polynom.div(&1, divisor))
  end

  defp compute_total_data_codewords(
         {_, blocks_in_group1, codewords_in_group1, blocks_in_group2, codewords_in_group2}
       ) do
    blocks_in_group1 * codewords_in_group1 + blocks_in_group2 * codewords_in_group2
  end

  defp group("", 0, _codewords) do
    []
  end

  defp group(data, blocks, codewords) do
    <<block_data::binary-size(codewords), rest::binary>> = data

    [block(block_data, codewords) | group(rest, blocks - 1, codewords)]
  end

  defp block("", 0) do
    []
  end

  defp block(<<codeword::size(8), rest::binary>>, codewords) do
    [codeword | block(rest, codewords - 1)]
  end
end
