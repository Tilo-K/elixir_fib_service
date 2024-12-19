defmodule FibService do
  use Application

  def start(_type, _args) do
    children = [
      {FibService.Worker, :some_initial_state} # Example child process
    ]

    opts = [strategy: :one_for_one, name: FibService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
