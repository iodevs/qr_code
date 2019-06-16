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

  @spec create(String.t(), level()) :: Result.t(String.t(), t())
  def create(orig, level \\ :low) when level(level) do
    %__MODULE__{orig: orig, ecc_level: level}
    |> QRCode.ByteMode.put_version()
    |> Result.map(&QRCode.DataEncoding.byte_encode/1)
    |> Result.map(&QRCode.ErrorCorrection.put/1)
    |> Result.map(&QRCode.Message.put/1)
    |> Result.and_then(&QRCode.Placement.put_patterns/1)
    |> Result.and_then(&QRCode.DataMasking.apply/1)

    # |> Result.map(&QRCode.FormatVersion.put_information/1)
  end
end
