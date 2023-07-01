defmodule Jobbex.Queue.Executor do
  alias Jobbex.{Job, Worker, Storage}

  @type state :: :failure | :success

  @type t :: %__MODULE__{
          duration: pos_integer(),
          job: Job.t(),
          state: :unset | state(),
          worker: Worker.t(),
          result: term(),
          error: nil | term()
        }

  defstruct [
    :duration,
    :job,
    :state,
    :worker,
    :result,
    :error
  ]

  @spec new(Job.t()) :: t()
  def new(job) do
    struct!(__MODULE__, %{
      duration: 0,
      job: job,
      state: :unset
    })
  end

  def call(executor) do
    executor
    |> resolve_worker()
    |> perform()
    |> report_finished()
  end

  def resolve_worker(%__MODULE__{job: job} = executor) do
    IO.inspect(job)

    case Worker.from_string(job.worker) do
      {:ok, worker} ->
        %{executor | worker: worker}

      {:error, error} ->
        %{executor | state: :failure, error: error, result: {:error, error}}
    end
  end

  def start_timeout(%__MODULE{state: :unset}) do
  end

  def report_finished(exec) do
    exec
    |> finalize_job()
  end

  def finalize_job(%__MODULE__{state: :success, job: job} = exec) do
    Storage.finish_job(job, :success)
    exec
  end

  def finalize_job(%__MODULE__{state: :failure, job: job} = exec) do
    Storage.finish_job(job, :failure)
    exec
  end

  def perform(%__MODULE__{job: job, state: :unset, worker: worker} = executor) do
    case worker.perform(job) do
      :ok ->
        %{executor | state: :success, result: :ok}

      {:ok, result} ->
        %{executor | state: :success, result: {:ok, result}}

      {:error, result} ->
        %{executor | state: :failure, result: {:error, result}}
    end
  rescue
    error ->
      %{executor | state: :failure, error: error}
  end

  def perform(executor), do: executor
end
