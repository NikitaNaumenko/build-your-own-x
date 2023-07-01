defmodule Jobbex.Queue.ExecutorTest do
  use ExUnit.Case, async: true

  alias Jobbex.Job
  alias Jobbex.Queue.Executor

  defmodule Worker do
    use Jobbex.Worker

    @impl Worker
    def perform(%{args: %{"mode" => "ok"}}), do: :ok
    def perform(%{args: %{"mode" => "result"}}), do: {:ok, :result}
    def perform(%{args: %{"mode" => "raise"}}), do: raise(ArgumentError)
    def perform(%{args: %{"mode" => "error"}}), do: {:error, "no reason"}
  end

  describe "perform/1" do
    test "returns ok" do
      assert %Executor{state: :success, result: :ok} = call("ok")
    end

    test "returns result" do
      assert %Executor{state: :success, result: {:ok, :result}} = call("result")
    end

    test "returns error" do
      assert %Executor{state: :failure, result: {:error, "no reason"}} = call("error")
    end

    test "performs with raise" do
      assert %Executor{state: :failure, result: nil, error: %ArgumentError{}} = call("raise")
    end

    test "performs catch" do
      assert %Executor{state: :failure, result: {:error, "no reason"}} = call("catch")
    end
  end

  defp call(mode) do
    %Job{args: %{"mode" => mode}, worker: to_string(Worker)}
    |> Executor.new()
    |> Executor.resolve_worker()
    |> Executor.perform()
  end
end
