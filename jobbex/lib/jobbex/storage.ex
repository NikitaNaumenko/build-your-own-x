defmodule Jobbex.Storage do
  @moduledoc false

  use GenServer, restart: :permanent

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], name: Keyword.get(opts, :name, __MODULE__))
  end

  def insert(job) do
    GenServer.call(__MODULE__, {:put, job})
  end

  def pop() do
    GenServer.call(__MODULE__, :pop)
  end

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:put, job}, _from, state) do
    {:reply, :ok, [job | state]}
  end

  def handle_call(:pop, _from, [] =  state) do
    {:reply, nil, state}
  end

  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end


end
