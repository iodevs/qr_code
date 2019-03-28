defmodule QRCode.Utils do
  @moduledoc """
  Helper functions.
  """

  def put_to_list(el, tpl) do
    el
    |> List.wrap()
    |> Kernel.++([tpl])
  end

  def save_csv(matrix, file_name \\ "tmp/qr_code.csv") do
    file_name
    |> File.open([:write], fn file ->
      matrix
      |> CSVLixir.write()
      |> Enum.each(&IO.write(file, &1))
    end)
  end

  def fake_data_ver_2() do
    for i <- List.duplicate(1, 359), do: <<i::1>>, into: <<>>
  end
end
