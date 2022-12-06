defmodule Generators.QR do
  @moduledoc false

  use PropCheck

  alias QRCode.CharacterCapacity, as: CC

  @levels [:low, :medium, :quartile, :high]
  @modes [:byte, :alphanumeric]
  @capacities (for mode <- @modes, into: %{} do
                 level_map =
                   for level <- @levels, into: %{} do
                     converted = for {m, l} <- CC.get_level(level, mode), into: %{}, do: {l, m}
                     {level, converted}
                   end

                 {mode, level_map}
               end)

  def level() do
    oneof([
      :low,
      :medium,
      :quartile,
      :high
    ])
  end

  def version() do
    let version <- range(1, 40) do
      version
    end
  end

  def get_capacity_for(_level, _version, mode \\ :byte)

  def get_capacity_for(_level, 0, _mode), do: 0

  def get_capacity_for(level, version, mode) do
    @capacities[mode][level][version]
  end
end
