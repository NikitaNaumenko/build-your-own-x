defmodule Jobbex.Queue.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: opts[:name])
  end

  @impl Supervisor
  def init(_opts) do
    children = []
    Supervisor.init(children, strategy: :one_for_one)
  end
end
