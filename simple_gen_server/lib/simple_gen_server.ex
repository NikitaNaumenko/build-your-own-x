defmodule SimpleGenServer do
  @moduledoc """
  Documentation for `SimpleGenServer`.
  """

  @doc """
    iex> pid = SimpleGenServer.start()
    iex> is_pid(pid)
    true
  """

  @callback init(initial_state :: any()) :: {:ok, any()}
  @callback handle_call(request :: term(), from :: pid(), state :: term()) ::
              {:reply, reply, new_state}
              | {:noreply, new_state}
              | {:stop, reason, reply, new_state}
              | {:stop, reason, new_state}
            when reply: term, new_state: term, reason: term
  @callback handle_cast(request :: term(), state :: term()) ::
    {:noreply, any()}
  @spec start :: pid
  def start() do
    state = []
    spawn(__MODULE__, :loop, [state])
  end

  @spec add(atom | pid | port | {atom, atom}, any) :: any
  def add(pid, item) do
    call(pid, {:add, item})
  end

  @spec call(atom | pid | port | {atom, atom}, any) :: any
  def call(pid, msg) do
    ref = Process.monitor(pid)
    send(pid, {:call, self(), ref, msg})

    receive do
      {:reply, ^ref, reply} ->
        Process.demonitor(ref, [:flush])
        reply

      {:DOWN, ^ref, :process, ^pid, reason} ->
        {:error, reason}
    after
      5000 ->
        :noreply
    end
  end

  def loop(state) do
    name = inspect(self())
    IO.puts("Start new server: #{name}, with state: #{inspect(state)}")

    receive do
      {:call, from, ref, msg} ->
        {reply, new_state} = handle_call(msg, state)
        send(from, {:reply, ref, reply})
        __MODULE__.loop(new_state)

      :stop ->
        IO.puts("server stopped")

      msg ->
        IO.puts("unhandled message: #{msg}")
        __MODULE__.loop(state)
    end
  end

  defp handle_call({:add, item}, state) do
    {:ok, [item | state]}
  end
end
