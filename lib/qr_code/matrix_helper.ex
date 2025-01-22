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

    # Copy qr code matrix to new matrix
    {:ok, new_matrix} = Matrix.update_map(new_matrix, matrix, [{quiet_zone, quiet_zone}])

    new_matrix
  end
end
