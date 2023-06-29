defmodule Jobbex.Application do
  @moduledoc false

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Jobbex.Registry},
      Jobbex.StorageSupervisor
    ]

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: __MODULE__
    )
  end
end
