defmodule DataMaskingTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use PropCheck

  alias MatrixReloaded.Matrix

  alias QRCode.{DataMasking, QR}
  alias Generators.QR, as: QRGenerator

  # Tests
  # Properties

  property "should choose mask pattern with lowest penalty" do
    forall qr <- qr() do
      result = DataMasking.apply(qr)

      check_lowest_penalty(result, qr)
    end
  end

  # Helpers

  defp check_lowest_penalty(result, %QR{matrix: matrix}) do
    [{index, penalty, _} | rest] =
      matrix
      |> DataMasking.masking_matrices()
      |> DataMasking.total_penalties()
      |> Enum.sort(fn {_, p1, _}, {_, p2, _} -> p1 <= p2 end)

    result.mask_num == index and Enum.all?(rest, fn {_, other, _} -> penalty <= other end)
  end

  # Generators

  defp qr() do
    let version <- QRGenerator.version() do
      dimension = 4 * version + 17

      matrix =
        dimension
        |> Matrix.new()
        |> elem(1)
        |> Enum.map(&Enum.map(&1, fn _ -> :rand.uniform(2) - 1 end))

      %QR{
        version: version,
        matrix: matrix
      }
    end
  end
end
