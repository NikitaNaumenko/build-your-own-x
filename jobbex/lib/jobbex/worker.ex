defmodule Jobbex.Worker do
  alias Jobbex.Job

  @type result ::
          :ok
          | {:ok, ignored :: term()}
          | {:error, reason :: term()}
  @callback perform(Job.t()) :: result()

  defmacro __using__(opts) do
    alias Jobbex.Worker

    @behaviour Worker
  end
end
