defmodule Jobbex.Worker do
  alias Jobbex.Job

  @type t :: module()
  @type result ::
          :ok
          | {:ok, ignored :: term()}
          | {:error, reason :: term()}
  @callback perform(Job.t()) :: result()

  defmacro __using__(opts) do
    quote location: :keep do
      alias Jobbex.Worker

      @behaviour Worker
    end
  end

  def from_string(worker_name) when is_binary(worker_name) do
    module =
      worker_name
      |> String.split()
      |> Module.safe_concat()

    if Code.ensure_loaded?(module) && function_exported?(module, :perform, 1) do
      {:ok, module}
    else
      {:error, RuntimeError.exception("given module #{worker_name} is not a worker")}
    end
  rescue
    ArgumentError ->
      {:error, RuntimeError.exception("unknown module - #{worker_name}")}
  end
end
