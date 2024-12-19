defmodule FibService.Worker do
  use GenServer
  require Logger

  def fib(n) when n < 2 do
    n
  end

  defp set_cache(n, f) do
    Agent.update(:kv, fn map -> Map.put(map, n, f) end)
  end

  defp get_cached(n) do
    Agent.get(:kv, fn map -> Map.get(map, n) end)
  end

  def fib(n) do
    cache = get_cached(n)

    if cache != nil do
      cache
    else
      f = fib(n - 1) + fib(n - 2)
      set_cache(n, f)
      f
    end
  end

  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accepting connections on :#{port}")
    loop_acceptor(socket)
  end

  def loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    spawn(fn -> serve(client) end)

    loop_acceptor(socket)
  end

  def serve(client) do
    line = client |> read_line()
    {iline, _} = Integer.parse(line)

    if iline < 9999 do
      f = fib(iline)
      :gen_tcp.send(client, Integer.to_string(f))
      :gen_tcp.send(client, "\n")

      serve(client)
    else
      :gen_tcp.send(client, "Komm mal runter Kollege\n")

      :gen_tcp.send(client, Text.what())

      serve(client)
    end
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0, 10000)
    data
  end

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
    {:ok, pid} = Agent.start_link(fn -> %{} end)
    Process.register(pid, :kv)
    accept(9001)
  end

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  @impl true
  def handle_call(:ping, _from, state) do
    {:reply, :pong, state}
  end

  @impl true
  def handle_cast(:work, state) do
    IO.puts("Working...")
    {:noreply, state}
  end
end
