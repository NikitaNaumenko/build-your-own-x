defmodule Jobbex.Job do
  @moduledoc false

  defstruct [:id, :worker, :max_attempts, :args, retries: 0, state: :new]
  @states ~w[new executing completed]

  @type state :: :new | :executing | :completed
  @type t :: %__MODULE__{
          id: String.t(),
          worker: String.t(),
          max_attempts: non_neg_integer(),
          args: map(),
          retries: non_neg_integer(),
          state: state()
        }
  def new(opts) do
    id = generate_id()
    max_attempts = Keyword.get(opts, :max_attempts, 3)
    args = Keyword.get(opts, :args, %{})
    worker = Keyword.get(opts, :worker, nil)
    %__MODULE__{id: id, max_attempts: max_attempts, args: args, worker: worker}
  end

  defp generate_id() do
    :crypto.strong_rand_bytes(5) |> Base.url_encode64(padding: false)
  end
end
