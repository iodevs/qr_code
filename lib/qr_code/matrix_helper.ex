defmodule QRCode.MatrixHelper do
  @moduledoc """
  Helper functions for matrix manipulation.
  """
  alias MatrixReloaded.Matrix

  @spec surround_matrix(Matrix.t(), integer(), integer()) :: Matrix.t()
  def surround_matrix(matrix, quiet_zone, value) when is_integer(quiet_zone) and quiet_zone >= 0 do
    {rows, cols} = Matrix.size(matrix)

    # Create new matrix with quiet zone
    {:ok, new_matrix} = Matrix.new({rows + 2 * quiet_zone, cols + 2 * quiet_zone}, value)

    # Copy matrix to new matrix
    new_matrix = Enum.reduce(0..rows - 1, new_matrix, fn row, acc_matrix ->
      Enum.reduce(0..cols - 1, acc_matrix, fn col, acc_matrix_inner ->
        {:ok, element} = Matrix.get_element(matrix, {row, col})
        {:ok, updated_matrix} = Matrix.update_element(acc_matrix_inner, element, {row + quiet_zone, col + quiet_zone})
        updated_matrix
      end)
    end)

    new_matrix
  end
end
