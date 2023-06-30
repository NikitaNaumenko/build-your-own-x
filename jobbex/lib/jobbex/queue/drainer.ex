defmodule Jobbex.Queue.Drainer do
  use GenServer

  @check_interval 10_000
  alias Jobbex.Storage
  alias Jobbex.Queue.Executor

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], name: Keyword.get(opts, :name, __MODULE__))
  end

  @impl GenServer
  def init(state) do
    {:ok, state, {:continue, :schedule_check}}
  end

  @impl GenServer
  def handle_continue(:schedule_check, state) do
    schedule_check()
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:check_jobs, state) do
    case Storage.pop() do
      nil ->
        schedule_check()
        {:noreply, state}
      job ->
        Executor.exec_job(job)
        {:noreply, [job.id]}
    end
  end

  defp schedule_check() do
    Process.send_after(self(), :check_jobs, @check_interval)
  end
end
