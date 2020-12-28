defmodule ErrorCorrectionTest do
  @moduledoc false
  use ExUnit.Case
  use PropCheck
  doctest QRCode.ErrorCorrection

  alias QRCode.{ErrorCorrection, QR}
  alias Generators.QR, as: QRGenerator

  # Tests

  # Properties

  @tag timeout: 180_000
  property "should have right split to groups and blocks" do
    forall qr <- qr() do
      qr
      |> ErrorCorrection.put()
      |> check_group_spliting()
    end
  end

  @tag timeout: 180_000
  property "should have correct number of error codewords" do
    forall qr <- qr() do
      qr
      |> ErrorCorrection.put()
      |> check_codewords_count()
    end
  end

  # Helpers

  defp check_group_spliting(%QR{ecc: ecc}) do
    {g1, g2} = ecc.groups

    length(g1) == ecc.blocks_in_group1 and
      length(g2) == ecc.blocks_in_group2 and
      Enum.all?(g1, fn block -> length(block) == ecc.codewords_per_block_in_group1 end) and
      Enum.all?(g2, fn block -> length(block) == ecc.codewords_per_block_in_group2 end)
  end

  defp check_codewords_count(%QR{ecc: ecc}) do
    {g1, g2} = ecc.codewords

    Enum.all?(g1, fn block -> length(block) == ecc.ec_codewrods_per_block end) and
      Enum.all?(g2, fn block -> length(block) == ecc.ec_codewrods_per_block end)
  end

  # Generators

  def qr() do
    let {level, version} <- {QRGenerator.level(), QRGenerator.version()} do
      qr = %QR{
        ecc_level: level,
        version: version
      }

      count = ErrorCorrection.total_data_codewords(qr)

      let encoded <- binary(count) do
        %QR{qr | encoded: encoded}
      end
    end
  end
end
