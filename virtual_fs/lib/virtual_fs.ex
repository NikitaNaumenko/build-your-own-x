defmodule VirtualFs do
  @moduledoc """
  Documentation for `VirtualFs`.
  """

  def start() do
    {:ok, _} = Application.ensure_all_started(:virtual_fs)
    :ok
  end
end
