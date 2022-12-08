defmodule DataEncodingTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use PropCheck
  doctest QRCode.DataEncoding

  alias QRCode.{DataEncoding, QR}
  alias Generators.QR, as: QRGenerator

  # Tests

  describe "count_bit_length/2" do
    test "below version 10" do
      assert 9 = DataEncoding.count_bit_length(:alphanumeric, 7)
    end

    test "version 9 to 26" do
      assert 11 = DataEncoding.count_bit_length(:alphanumeric, 17)
    end

    test "versions 27 to 40" do
      assert 13 = DataEncoding.count_bit_length(:alphanumeric, 33)
    end

    test "fails if an invalid mode is provided" do
      assert_raise FunctionClauseError, fn ->
        DataEncoding.count_bit_length(:badatom, 33)
      end
    end
  end

  describe "mode_indicator_byte/1" do
    test "returns a 4 bit mode" do
      assert 0b0100 = DataEncoding.mode_indicator_byte(:byte)
    end

    test "fails if an invalid mode is provided" do
      assert_raise FunctionClauseError, fn ->
        DataEncoding.mode_indicator_byte(:badatom)
      end
    end
  end

  #  describe "encode/1" do
  #    test "do stuff" do
  #
  #    end
  #
  #    test "fails if an invalid mode is provided" do
  #
  #    end
  #  end
  # Properties

  #  # Helpers

  # Generators

  def qr() do
    let {level, version} <- {QRGenerator.level(), QRGenerator.version()} do
      lower = QRGenerator.get_capacity_for(level, version - 1)
      upper = QRGenerator.get_capacity_for(level, version)
      diff = upper - lower
      count = :rand.uniform(diff) + lower

      let message <- binary(count) do
        %QR{
          ecc_level: level,
          version: version,
          orig: message
        }
      end
    end
  end
end
