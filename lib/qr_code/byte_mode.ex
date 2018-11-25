defmodule QRCode.ByteMode do
  @moduledoc """
  Byte mode character capacities table.
  """

  alias QRCode.QR

  @level_low [
    {17, 1},
    {32, 2},
    {53, 3},
    {78, 4},
    {106, 5},
    {134, 6},
    {154, 7},
    {192, 8},
    {230, 9},
    {271, 10},
    {321, 11},
    {367, 12},
    {425, 13},
    {458, 14},
    {520, 15},
    {586, 16},
    {644, 17},
    {718, 18},
    {792, 19},
    {858, 20},
    {929, 21},
    {1003, 22},
    {1091, 23},
    {1171, 24},
    {1273, 25},
    {1367, 26},
    {1465, 27},
    {1528, 28},
    {1628, 29},
    {1732, 30},
    {1840, 31},
    {1952, 32},
    {2068, 33},
    {2188, 34},
    {2303, 35},
    {2431, 36},
    {2563, 37},
    {2699, 38},
    {2809, 39},
    {2953, 40}
  ]
  @level_medium [
    {14, 1},
    {26, 2},
    {42, 3},
    {62, 4},
    {84, 5},
    {106, 6},
    {122, 7},
    {152, 8},
    {180, 9},
    {213, 10},
    {251, 11},
    {287, 12},
    {331, 13},
    {362, 14},
    {412, 15},
    {450, 16},
    {504, 17},
    {560, 18},
    {624, 19},
    {666, 20},
    {711, 21},
    {779, 22},
    {857, 23},
    {911, 24},
    {997, 25},
    {1059, 26},
    {1125, 27},
    {1190, 28},
    {1264, 29},
    {1370, 30},
    {1452, 31},
    {1538, 32},
    {1628, 33},
    {1722, 34},
    {1809, 35},
    {1911, 36},
    {1989, 37},
    {2099, 38},
    {2213, 39},
    {2331, 40}
  ]
  @level_quartile [
    {11, 1},
    {20, 2},
    {32, 3},
    {46, 4},
    {60, 5},
    {74, 6},
    {86, 7},
    {108, 8},
    {130, 9},
    {151, 10},
    {177, 11},
    {203, 12},
    {241, 13},
    {258, 14},
    {292, 15},
    {322, 16},
    {364, 17},
    {394, 18},
    {442, 19},
    {482, 20},
    {509, 21},
    {565, 22},
    {611, 23},
    {661, 24},
    {715, 25},
    {751, 26},
    {805, 27},
    {868, 28},
    {908, 29},
    {982, 30},
    {1030, 31},
    {1112, 32},
    {1168, 33},
    {1228, 34},
    {1283, 35},
    {1351, 36},
    {1423, 37},
    {1499, 38},
    {1579, 39},
    {1663, 40}
  ]
  @level_high [
    {7, 1},
    {14, 2},
    {24, 3},
    {34, 4},
    {44, 5},
    {58, 6},
    {64, 7},
    {84, 8},
    {98, 9},
    {119, 10},
    {137, 11},
    {155, 12},
    {177, 13},
    {194, 14},
    {220, 15},
    {250, 16},
    {280, 17},
    {310, 18},
    {338, 19},
    {382, 20},
    {403, 21},
    {439, 22},
    {461, 23},
    {511, 24},
    {535, 25},
    {593, 26},
    {625, 27},
    {658, 28},
    {698, 29},
    {742, 30},
    {790, 31},
    {842, 32},
    {898, 33},
    {958, 34},
    {983, 35},
    {1051, 36},
    {1093, 37},
    {1139, 38},
    {1219, 39},
    {1273, 40}
  ]

  @spec put_version(QR.t()) :: Result.t(String.t(), QR.t())
  def put_version(%QR{orig: orig, ecc_level: :low} = qr) do
    @level_low
    |> find_version(byte_size(orig))
    |> Result.map(fn ver -> %{qr | version: ver} end)
  end

  def put_version(%QR{orig: orig, ecc_level: :medium} = qr) do
    @level_medium
    |> find_version(byte_size(orig))
    |> Result.map(fn ver -> %{qr | version: ver} end)
  end

  def put_version(%QR{orig: orig, ecc_level: :quartile} = qr) do
    @level_quartile
    |> find_version(byte_size(orig))
    |> Result.map(fn ver -> %{qr | version: ver} end)
  end

  def put_version(%QR{orig: orig, ecc_level: :high} = qr) do
    @level_high
    |> find_version(byte_size(orig))
    |> Result.map(fn ver -> %{qr | version: ver} end)
  end

  defp find_version(level, bytes) do
    Enum.reduce_while(level, {:error, "Input string can't be encoded"}, fn {max, ver}, acc ->
      if bytes <= max do
        {:halt, {:ok, ver}}
      else
        {:cont, acc}
      end
    end)
  end
end
