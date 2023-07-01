defmodule Jobbex.Storage do
  @moduledoc false

  use GenServer, restart: :permanent

  defmodule State do
    defstruct queue: [],
              finished: [],
              failed: []

    def put_queue(state, job) do
      {:ok, %{state | queue: [job | state.queue]}}
    end

    def pop_queue(%{queue: []} = state) do
      {nil, state}
    end

    def pop_queue(%{queue: [head | tail]} = state) do
      {head, %{state | queue: tail}}
    end

    def store_finished_job(%{completed: completed} = state, job, :success) do
      %{state | completed: [%{job | state: :completed} | completed]}
    end

    def store_finished_job(%{failed: failed} = state, job, :failure) do
      %{state | failed: [%{job | state: :failed} | failed]}
    end
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %State{}, name: Keyword.get(opts, :name, __MODULE__))
  end

  def insert(job) do
    GenServer.call(__MODULE__, {:put, job})
  end

  def pop() do
    GenServer.call(__MODULE__, :pop)
  end

  def finish_job(job, resolution) do
    GenServer.call(__MODULE__, {:finish_job, job, resolution})
  end

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:put, job}, _from, state) do
    {:ok, state} = State.put_queue(state, job)
    {:reply, :ok, state}
  end

  def handle_call(:pop, _from, state) do
    {job, state} = State.pop_queue(state)
    {:reply, job, state}
  end

  def handle_call({:finish_job, job, resolution}, _from, state) do
    state = State.store_finished_job(state, job, resolution)
    {:reply, :ok, state}
  end
end
