defmodule QRCode.CharacterCapacityTest do
  use ExUnit.Case, async: true

  alias QRCode.CharacterCapacity

  doctest CharacterCapacity

  describe "get_level/2" do
    test "returns low level for alphanumeric" do
      levels = CharacterCapacity.get_level(:low, :alphanumeric)
      assert {25, 1} = hd(levels)
    end

    test "returns low level for byte" do
      levels = CharacterCapacity.get_level(:low, :byte)
      assert {17, 1} = hd(levels)
    end
  end

  describe "get_capacity/4" do
    test "returns a character count" do
      assert 17 = CharacterCapacity.get_capacity(:low, :byte, 1)
    end

    test "returns a bit count" do
      assert 136 = CharacterCapacity.get_capacity(:low, :byte, 1, :bits)
    end
  end
end
