defmodule Jobbex do
  @moduledoc """
  Documentation for `Jobbex`.
  """

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(_opts) do
    Supervisor.init([], strategy: :one_for_one)
  end
end
