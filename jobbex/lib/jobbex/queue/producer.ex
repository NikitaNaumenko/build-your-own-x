defmodule Jobbex.Queue.Producer do
  use GenServer

  @check_interval 10_000
  alias Jobbex.{Storage, Foreman}
  alias Jobbex.Queue.Executor

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{running: %{}}, name: Keyword.get(opts, :name, __MODULE__))
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
        exec = Executor.new(job)
        task = Task.Supervisor.async_nolink(Jobbex.Foreman, Executor, :call, [exec])
        schedule_check()

        {:noreply, %{state | running: Map.put(state.running, task.ref, {task.pid, exec})}}
    end
  end

  def handle_info({ref, _val}, state) do
    state = free_ref(state, ref)

    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, pid, reason}, state) do
    {^pid, exec} = Map.get(state.running, ref)

    exec =
      case reason do
        {error, stack} ->
          %{exec | kind: {:EXIT, pid}, error: error, stacktrace: stack, state: :failure}

        _ ->
          %{exec | kind: {:EXIT, pid}, error: reason, state: :failure}
      end

    Task.Supervisor.async_nolink(Foreman, fn ->
      Executor.report_finished(exec)
    end)

    state =
      free_ref(state, ref)

    {:noreply, state}
  end

  defp schedule_check() do
    Process.send_after(self(), :check_jobs, @check_interval)
  end

  defp free_ref(state, ref) do
    Process.demonitor(ref, [:flush])

    %{state | running: Map.delete(state.running, ref)}
  end
end
