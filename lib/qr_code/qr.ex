defmodule QRCode.QR do
  @moduledoc """
  QR code data structure
  """

  @type level() :: :low | :medium | :quartile | :high
  @type version() :: 1..40
  @type mode() :: :numeric | :alphanumeric | :byte | :kanji | :eci
  @type t() :: %__MODULE__{
          orig: Maybe.t(String.t()),
          encoded: Maybe.t(binary()),
          version: Maybe.t(version()),
          ecc_level: level(),
          mode: mode(),
          groups: tuple()
        }

  @levels [:low, :medium, :quartile, :high]
  @modes [
    numeric: 0b0001,
    alphanumeric: 0b0010,
    byte: 0b0100,
    kanji: 0b1000,
    eci: 0b0111
  ]

  defstruct orig: nil,
            encoded: nil,
            version: nil,
            ecc_level: :low,
            mode: :byte,
            groups: {[], []}

  defguard level(lvl) when lvl in @levels
  defguard version(v) when v in 1..40

  @spec create(String.t(), level()) :: t()
  def create(orig, level \\ :low) when level(level) do
    %QR{orig: orig, ecc_level: level}
  end
end
