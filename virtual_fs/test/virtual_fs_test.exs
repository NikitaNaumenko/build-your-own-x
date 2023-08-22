defmodule VirtualFsTest do
  use ExUnit.Case
  # doctest VirtualFs

  test "start virtual fs application" do
    assert VirtualFs.start() == :ok
  end
end
