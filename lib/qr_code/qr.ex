defmodule QRCode.QR do
  @moduledoc """
  QR code data structure
  """

  alias QRCode.ErrorCorrection

  @type level() :: :low | :medium | :quartile | :high
  @type version() :: 1..40
  @type mode() :: :numeric | :alphanumeric | :byte | :kanji | :eci
  @type mask_num() :: 0..7
  @type groups() :: {[[], ...], [[]]}
  @type t() :: %__MODULE__{
          orig: ExMaybe.t(String.t()),
          encoded: ExMaybe.t(binary()),
          version: ExMaybe.t(version()),
          ecc_level: level(),
          ecc: ExMaybe.t(ErrorCorrection.t()),
          message: ExMaybe.t(String.t()),
          mode: mode(),
          matrix: MatrixReloaded.Matrix.t(),
          mask_num: mask_num()
        }

  @levels [:low, :medium, :quartile, :high]
  # @modes [
  #   numeric: 0b0001,
  #   alphanumeric: 0b0010,
  #   byte: 0b0100,
  #   kanji: 0b1000,
  #   eci: 0b0111
  # ]

  defstruct orig: nil,
            encoded: nil,
            version: nil,
            ecc_level: :low,
            ecc: nil,
            message: nil,
            mode: :byte,
            matrix: [[]],
            mask_num: 0

  defguard level(lvl) when lvl in @levels
  defguard version(v) when v in 1..40
  defguard masking(m) when m in 0..7

  @doc """
  Creates QR code. You can change the error correction level according to your needs.
  There are four level of error correction: `:low | :medium | :quartile | :high`
  where `:low` is default value.

  This function returns  [Result](https://hexdocs.pm/result/api-reference.html),
  it means either tuple of `{:ok, QR.t()}` or `{:error, "msg"}`.

  ##  Example:
      iex> QRCode.QR.create("Hello World")
      {:ok,
      %QRCode.QR{
        ecc: %QRCode.ErrorCorrection{
          blocks_in_group1: 1,
          blocks_in_group2: 0,
          codewords: {[[139, 194, 132, 243, 72, 115, 10]], []},
          codewords_per_block_in_group1: 19,
          codewords_per_block_in_group2: 0,
          ec_codewrods_per_block: 7,
          groups: {[
              [64, 180, 134, 86, 198, 198, 242, 5, 118, 247, 38, 198, 64, 236, 17,
              236, 17, 236, 17]
            ], []}
        },
        ecc_level: :low,
        encoded: <<64, 180, 134, 86, 198, 198, 242, 5, 118, 247, 38, 198, 64, 236,
          17, 236, 17, 236, 17>>,
        mask_num: 0,
        matrix: [
          [1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1],
          [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
          [1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1],
          [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1],
          [1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1],
          [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1],
          [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
          [1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0],
          [0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1],
          [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1],
          [0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0],
          [1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0],
          [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1],
          [1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1],
          [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0],
          [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0],
          [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
          [1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0],
          [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 1]
        ],
        message: <<64, 180, 134, 86, 198, 198, 242, 5, 118, 247, 38, 198, 64, 236,
          17, 236, 17, 236, 17, 139, 194, 132, 243, 72, 115, 10>>,
        mode: :byte,
        orig: "Hello World",
        version: 1
      }}

  For saving QR code to svg file, use `QRCode.Svg.save_as/3` function:

      iex> qr = QRCode.QR.create("Hello World", :high)
      iex> qr |> Result.and_then(&QRCode.Svg.save_as(&1,"hello.svg"))
      {:ok, "hello.svg"}

  The svg file will be saved into your project directory.
  """
  @spec create(String.t(), level()) :: Result.t(String.t(), t())
  def create(orig, level \\ :low) when level(level) do
    %__MODULE__{orig: orig, ecc_level: level}
    |> QRCode.ByteMode.put_version()
    |> Result.map(&QRCode.DataEncoding.byte_encode/1)
    |> Result.map(&QRCode.ErrorCorrection.put/1)
    |> Result.map(&QRCode.Message.put/1)
    |> Result.and_then(&QRCode.Placement.put_patterns/1)
    |> Result.map(&QRCode.DataMasking.apply/1)
    |> Result.and_then(&QRCode.Placement.replace_placeholders/1)
    |> Result.and_then(&QRCode.FormatVersion.put_information/1)
  end

  @doc """
  The same as `create/2`, but raises a `QRCode.Error` exception if it fails.
  """
  @spec create!(String.t(), level()) :: t()
  def create!(text, level \\ :low) when level(level) do
    case create(text, level) do
      {:ok, qr} -> qr
      {:error, msg} -> raise QRCode.Error, message: msg
    end
  end
end
