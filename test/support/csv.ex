defmodule Csv do
  @moduledoc false

  @path_to_patterns "test/patterns/"
  @file_format ".csv"

  def read_file(name) do
    [@path_to_patterns, "pattern_" <> name, @file_format]
    |> Enum.join()
    |> File.stream!()
    |> Stream.map(&String.trim(&1))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn row -> row |> Stream.map(&String.to_integer/1) |> Enum.to_list() end)
    |> Enum.to_list()
    |> Result.ok()
  end
end
