defmodule Jobbex.Queue.Executor do
  alias Jobbex.{Job, Worker}

  @type state :: :failure | :success

  @type t :: %__MODULE{
          duration: pos_integer(),
          job: Job.t(),
          state: :unset | state()
        }

  @spec new(Job.t()) :: t()
  def new(job) do
    struct!(%{
      duration: 0,
      job: job,
      state: :unset
    })
  end

  def call(executor) do
    executor
    |> resolve_worker()
    |> start_timeout()
    |> perform()
    |> set_state()
    |> stop_timeout()
    |> report_finished()
  end

  def resolve_worker(%Job{worker: worker}) do
    case Worker.from_string(worker) do
      {:ok, worker} ->
        {:ok, worker}

      {:error, error} ->
        {:error, error}
    end
  end
end
