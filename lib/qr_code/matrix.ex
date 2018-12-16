defmodule QRCode.Matrix do
  @moduledoc """
  Provides a set of functions to work with matrix as
  creating / updating /... .

  This module will be used for generating QR code matrix.
  """

  @type row :: [pos_integer]
  @type matrix :: [row]
  @type dimension :: {pos_integer, pos_integer} | pos_integer
  @type index :: {pos_integer, pos_integer}
  @type element :: number | matrix

  @doc """
  Create a new matrix of the specified size (number of rows and columns).
  Values `row` and `column` must be positive integer. Otherwise you get error
  message. All elements of the matrix are filled with the default value 0.
  This value can be changed. See example below.

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ## Examples

      iex> QRCode.Matrix.new(3)
      {:ok, [[0, 0, 0], [0, 0, 0], [0, 0, 0]]}

      iex> QRCode.Matrix.new({2, 3}, -10)
      {:ok, [[-10, -10, -10], [-10, -10, -10]]}

  """
  @spec new(dimension, number) :: Result.t(String.t(), matrix)
  def new(dimension, val \\ 0)

  def new({rows, cols}, val) when rows > 0 and cols > 0 do
    for(
      _r <- 1..rows,
      do: make_row(cols, val)
    )
    |> Result.ok()
  end

  def new(rows, val) when rows > 0 do
    for(
      _r <- 1..rows,
      do: make_row(rows, val)
    )
    |> Result.ok()
  end

  def new({_rows, _cols}, _val) do
    Result.error("It is not possible create the matrix with negative row or column!")
  end

  def new(_rows, _val) do
    Result.error("It is not possible create square matrix with negative row or column!")
  end

  @doc """
  Updates the matrix by given a submatrix. The position of submatrix inside matrix
  is given by two indexes `{from_row, from_col}` and `{to_row, to_col}`. These
  indexes must reflect the size of submatrix. Size of submatrix must be less than
  or equal to size of matrix. Otherwise (in both cases) you get error message.
  The values of indexes start from 0 to (matrix row size - 1). Similarly for col size.

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ##  Example:

      iex> QRCode.Matrix.new(4) |> Result.and_then(&QRCode.Matrix.update(&1, {1,2}, {2,3}, [[1,2],[3,4]]))
      {:ok,
        [
          [0, 0, 0, 0],
          [0, 0, 1, 2],
          [0, 0, 3, 4],
          [0, 0, 0, 0]
        ]
      }

  """
  @spec update(matrix, index, index, element) :: Result.t(String.t(), matrix)
  def update(matrix, index1, index2, submatrix) do
    matrix
    |> are_indexes_same_as_size_of_submatrix?(index1, index2, submatrix)
    |> Result.and_then(&is_possible_insert_submatrix_to_matrix?(&1, submatrix))
    |> Result.map(&make_update(&1, index1, index2, submatrix))
  end

  @doc """
  Updates the matrix by given a number. The position of element in matrix
  which you want to change is given by two positive integers. These numbers
  must be from 0 to (matrix row size - 1). Similarly for col size.

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ##  Example:

      iex> QRCode.Matrix.new(3) |> Result.and_then(&QRCode.Matrix.update_element(&1, 1, 1, -1))
      {:ok,
        [
          [0, 0, 0],
          [0, -1, 0],
          [0, 0, 0]
        ]
      }

  """
  @spec update_element(matrix, pos_integer, pos_integer, number) :: Result.t(String.t(), matrix)
  def update_element(matrix, row, col, el) when is_number(el) do
    update(matrix, {row, col}, {row, col}, [[el]])
  end

  @doc """
  Updates row in the matrix by given a vector (list) of numbers. The row which
  you want to change is given by positive integer (from 0 to (matrix row size - 1)),
  by tuple `{from_col, to_col}` and by list of values. Values of tuple must reflect
  the size of list. Otherwise you get error message.

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ##  Example:

      iex> {:ok, mat} = QRCode.Matrix.new(4)
      iex> QRCode.Matrix.update_row(mat, 3, {0, 2}, [1, 2, 3])
      {:ok,
        [
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [1, 2, 3, 0]
        ]
      }

  """
  @spec update_row(matrix, pos_integer, index, element) :: Result.t(String.t(), matrix)
  def update_row(matrix, row, {from_col, to_col}, submatrix) do
    update(matrix, {row, from_col}, {row, to_col}, [submatrix])
  end

  @doc """
  Updates column in the matrix by given a vector (list) of numbers. The column which
  you want to change is given by positive integer (from 0 to (matrix col size - 1)),
  by tuple `{from_row, to_row}` and by list of values. Values of tuple must reflect
  the size of list. Otherwise you get error message.

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ##  Example:

      iex> {:ok, mat} = QRCode.Matrix.new(4)
      iex> QRCode.Matrix.update_col(mat, 1, {0, 2}, [[1], [2], [3]])
      {:ok,
        [
          [0, 1, 0, 0],
          [0, 2, 0, 0],
          [0, 3, 0, 0],
          [0, 0, 0, 0]
        ]
      }

  """
  @spec update_col(matrix, pos_integer, index, element) :: Result.t(String.t(), matrix)
  def update_col(matrix, col, {from_row, to_row}, submatrix) do
    update(matrix, {from_row, col}, {to_row, col}, submatrix)
  end

  @doc """
  Updates the matrix by given a submatrices. The positions (or locations) of these
  submatrices are given by list of indices. Index of the individual submatrices is
  tuple of two numbers. These two numbers are row and column of matrix where the
  submatrices will be located. All submatrices must have same size (dimension).

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ##  Example:

      iex> mat = QRCode.Matrix.new(5)
      iex> sub_mat = QRCode.Matrix.new(2,1)
      iex> positions = [{0,0}, {3, 3}]
      iex> QRCode.Matrix.update_map(mat, positions, sub_mat)
      {:ok,
        [
          [1, 1, 0, 0, 0],
          [1, 1, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 1, 1],
          [0, 0, 0, 1, 1]
        ]
      }

  """
  @spec update_map(matrix, list(index), {:ok, element}) :: Result.t(String.t(), matrix)
  def update_map(matrix, positions, submatrix) do
    {row, col, check_size} = check_size(matrix, submatrix, positions)

    if check_size do
      Enum.reduce(positions, matrix, fn {row_pos, col_pos}, acc ->
        and_then2(
          acc,
          submatrix,
          &update(&1, {row_pos, col_pos}, {row_pos + row - 1, col_pos + col - 1}, &2)
        )
      end)
    else
      Result.error("Bad value of position {#{row}, #{col}}. Submatrix is out of matrix!")
    end
  end

  @doc """
  The size (dimensions) of the matrix.

  Returns tuple of {row_size, col_size}.

  ## Example:

      iex> QRCode.Matrix.new({3,4}) |> Result.and_then(&QRCode.Matrix.size(&1))
      {3, 4}

  """
  @spec size(matrix) :: {pos_integer, pos_integer}
  def size(matrix), do: {length(matrix), length(List.first(matrix))}

  defp make_row(0, _val), do: []
  defp make_row(n, val), do: [val] ++ make_row(n - 1, val)

  defp are_indexes_same_as_size_of_submatrix?(
         matrix,
         {from_row, from_col},
         {to_row, to_col},
         submatrix
       ) do
    {row_size, col_size} = size(submatrix)
    calculated_row_size = to_row - from_row + 1
    calculated_col_size = to_col - from_col + 1

    if calculated_row_size == row_size and calculated_col_size == col_size do
      Result.ok(matrix)
    else
      Result.error(
        "Size {#{row_size}, #{col_size}} of submatrix is different from calculated indices {#{
          calculated_row_size
        }, #{calculated_col_size}}!"
      )
    end
  end

  defp is_possible_insert_submatrix_to_matrix?(
         matrix,
         submatrix
       ) do
    {row_size, col_size} = size(matrix)
    {row_size_sub, col_size_sub} = size(submatrix)

    if row_size_sub <= row_size and col_size_sub <= col_size do
      Result.ok(matrix)
    else
      Result.error("Size of submatrix is bigger than size of matrix!")
    end
  end

  defp make_update(matrix, {from_row, from_col}, {to_row, to_col}, submatrix) do
    matrix
    |> Enum.with_index()
    |> Enum.map(fn {row, i} ->
      if i in from_row..to_row do
        row
        |> Enum.with_index()
        |> Enum.map(fn {_col, j} ->
          if j in from_col..to_col do
            submatrix |> Enum.at(i - from_row) |> Enum.at(j - from_col)
          else
            Enum.at(row, j)
          end
        end)
      else
        row
      end
    end)
  end

  defp and_then2({:ok, val1}, {:ok, val2}, f) when is_function(f, 2) do
    f.(val1, val2)
  end

  defp and_then2({:error, _} = result, _, _f), do: result
  defp and_then2(_, {:error, _} = result, _f), do: result

  defp check_size(matrix, submatrix, positions) do
    {rm, cm} = matrix |> Result.and_then(&size(&1))
    {rs, cs} = submatrix |> Result.and_then(&size(&1))

    Enum.reduce_while(
      positions,
      {rs, cs, true},
      fn {row_pos, col_pos}, acc ->
        if rs + row_pos <= rm and cs + col_pos <= cm do
          {:cont, acc}
        else
          {:halt, {row_pos, col_pos, false}}
        end
      end
    )
  end
end
