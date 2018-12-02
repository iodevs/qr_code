defmodule QRCode.Vector do
  @moduledoc """
  Provides a set of functions to work with vector as
  creating / updating /... .

  This module will be used for generating QR code matrix.
  """

  @type vector :: list(number)

  @doc """
  Create a vector of the specified size. Default values of vector is set to 0.
  This value can be changed. See example below.

  Returns list of numbers.

  ## Examples

      iex> QRCode.Vector.new(4)
      [0, 0, 0, 0]

      iex> QRCode.Vector.new(4, 3.9)
      [3.9, 3.9, 3.9, 3.9]

  """

  @spec new(pos_integer, number) :: vector()
  def new(size, val \\ 0) do
    List.duplicate(val, size)
  end

  @doc """
  The size of the vector.

  Returns a positive integer.

  ## Example:

      iex> QRCode.Vector.new(3) |> QRCode.Vector.size()
      3

  """
  @spec size(vector) :: pos_integer
  def size(vec), do: length(vec)
end
