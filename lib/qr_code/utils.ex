defmodule QRCode.Utils do
  @moduledoc """
  Helper functions.
  """

  def put_to_list(el, tpl) do
    el
    |> List.wrap()
    |> Kernel.++([tpl])
  end
end
