defmodule KVWorker.Application do

  use Application

  require Logger

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: KVWorker.Worker.start_link(arg)
      # {KVWorker.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    #opts = [strategy: :one_for_one, name: KVWorker.Supervisor]
    #Supervisor.start_link(children, opts)

    KVWorker.Supervisor.start_link(
      Application.get_env(:worker, :max_entry_count)
    )

  end


end
