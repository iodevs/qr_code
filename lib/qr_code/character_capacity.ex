defmodule QRCode.CharacterCapacity do
  @moduledoc """
  Character capacities version helper.
  """

  alias QRCode.{AlphanumericMode, ByteMode, QR}

  @type version :: 1..40
  @type level_list :: list({integer(), version()})
  @type level :: :low | :medium | :quartile | :high
  @type mode :: :byte | :alphanumeric
  @type capacity_unit :: :bits | :characters

  @callback level_low() :: list({integer(), integer()})
  @callback level_medium() :: list({integer(), integer()})
  @callback level_quartile() :: list({integer(), integer()})
  @callback level_high() :: list({integer(), integer()})

  @levels [:low, :medium, :quartile, :high]
  @modes [:byte, :alphanumeric]

  defguard is_level(value) when value in @levels
  defguard is_mode(value) when value in @modes
  defguard is_version(value) when is_integer(value) and value > 0 and value <= 40

  def put_version(%QR{mode: :byte} = qr) do
    ByteMode.put_version(qr)
  end

  def put_version(%QR{mode: :alphanumeric} = qr) do
    AlphanumericMode.put_version(qr)
  end

  @spec get_level(level(), mode()) :: level_list()
  def get_level(level, mode) when is_level(level) and is_mode(mode) do
    module =
      case mode do
        :byte -> ByteMode
        :alphanumeric -> AlphanumericMode
      end

    case level do
      :low -> module.level_low()
      :medium -> module.level_medium()
      :quartile -> module.level_quartile()
      :high -> module.level_high()
    end
  end

  @spec get_capacity(level(), mode(), capacity_unit()) :: integer()
  def get_capacity(level, mode, version, unit \\ :character) when is_version(version) do
    level_list = get_level(level, mode)
    characters = level_list |> Enum.at(version - 1) |> elem(0)

    case unit do
      :bits -> characters * 8
      _ -> characters
    end
  end

  defmacro __using__(_opts) do
    quote do
      alias QRCode.QR

      @behaviour QRCode.CharacterCapacity

      @compile {:inline, level_low: 0}
      @compile {:inline, level_medium: 0}
      @compile {:inline, level_quartile: 0}
      @compile {:inline, level_high: 0}

      @spec put_version(QR.t()) :: Result.t(String.t(), QR.t())
      def put_version(%QR{orig: orig, ecc_level: :low} = qr) do
        level_low()
        |> find_version(byte_size(orig))
        |> Result.map(fn ver -> %{qr | version: ver} end)
      end

      def put_version(%QR{orig: orig, ecc_level: :medium} = qr) do
        level_medium()
        |> find_version(byte_size(orig))
        |> Result.map(fn ver -> %{qr | version: ver} end)
      end

      def put_version(%QR{orig: orig, ecc_level: :quartile} = qr) do
        level_quartile()
        |> find_version(byte_size(orig))
        |> Result.map(fn ver -> %{qr | version: ver} end)
      end

      def put_version(%QR{orig: orig, ecc_level: :high} = qr) do
        level_high()
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
  end
end
