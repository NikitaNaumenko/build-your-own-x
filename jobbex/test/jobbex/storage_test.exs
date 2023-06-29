defmodule Jobbex.StorageTest do
  use ExUnit.Case, async: true

  alias Jobbex.{Job, Storage}

  setup do
    {:ok, pid} = start_supervised({Storage, name: TestStorage})
    {:ok, %{pid: pid}}
  end

  describe "insert/2" do
    test "insert job", %{pid: pid} do
      job = Job.new(worker: inspect(Worker), args: %{})
      assert :ok = GenServer.call(pid, {:put, job})
    end
  end

  describe "pop/0" do
    test "pop job from empty queue", %{pid: pid} do
      assert nil == GenServer.call(pid, :pop)
    end

    test "pop job", %{pid: pid} do
      job = Job.new(worker: inspect(Worker), args: %{})
      assert :ok = GenServer.call(pid, {:put, job})
      assert ^job = GenServer.call(pid, :pop)
    end
  end
end
