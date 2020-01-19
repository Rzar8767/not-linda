defmodule NL.Environment do
  use GenServer
  require Logger

  # Client

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  # odczytanie i jednoczesne usunięcie krotki z przestrzeni krotek
  def space_in(fun) do
    # fun = fn {:coal, _x, _y} -> true; _el -> false end
    GenServer.call(NL.Environment, {:in, fun})
  end

  # odczytanie krotki z przestrzeni krotek bez jej usunięcia
  def space_rd(fun) do
    GenServer.call(NL.Environment, {:rd, fun})
  end

  # stworzenie krotki i jej umieszczenie w przestrzeni krotek
  def space_out(tuple) when is_tuple(tuple) do
    GenServer.call(NL.Environment, {:out, tuple})
  end

  # Server (callbacks)
  # Based on http://wiki.c2.com/?TupleSpace
  # and https://pl.wikipedia.org/wiki/Linda_(j%C4%99zyk_programowania)

  @impl true
  def init(list) do
    list = [{:axe}, {:pickaxe}] ++ list
    Logger.info("Initial state of the tuplespace: #{inspect(list)}")
    {:ok, list}
  end

  @impl true
  def handle_call({:in, fun}, _from, tuplespace) do
    {return, new_ts} = match_tuple(tuplespace, fun, 1)
    {:reply, return, new_ts}
  end

  @impl true
  def handle_call({:rd, fun}, _from, tuplespace) do
    {return, _new_ts} = match_tuple(tuplespace, fun, 1)
    {:reply, return, tuplespace}
  end

  @impl true
  def handle_call({:out, tuple}, _from, tuplespace) when is_tuple(tuple) do
    Logger.info("Element #{inspect(tuple)} added to the tuplespace.")
    {:reply, :ok, [tuple | tuplespace]}
  end

  defp match_tuple(list, fun, count) do
    # could be rewritten using Enum.reduce_while/3
    {match, rest} = Enum.split_with(list, fun)
    {count, leftover} = Enum.split(match, count)

    {count, leftover ++ rest}
  end
end
