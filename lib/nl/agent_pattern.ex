defmodule NL.AgentPattern do
  import NL.Environment
  require Logger

  def get_resource(name) when is_atom(name) do
    fun = fn
      {^name} -> true
      _el -> false
    end

    case space_in(fun) do
      [item] ->
        item

      [] ->
        Process.sleep(1000)
        get_resource(name)
    end
  end

  def get_axe() do
    get_resource(:axe)
  end

  def get_pickaxe() do
    get_resource(:pickaxe)
  end

  def woodcutter() do
    get_axe()
    Logger.info("Woodcutter has acquired axe from the environment, cutting trees.")

    Enum.each(1..3, fn _el ->
      space_out({:wood})
      Process.sleep(2000)
    end)

    woodcutter()
  end

  def miner() do
    get_pickaxe()
    Logger.info("Miner has acquired pickaxe from the environment, mining ore.")

    Enum.each(1..2, fn _el ->
      space_out({:ore})
      Process.sleep(500)
    end)

    miner()
  end

  def smith() do
    _resources = Task.async_stream([:wood, :ore], &get_resource(&1))
    Logger.info("Smith has acquired steel and wood from the environment, producing tools.")

    Enum.each(1..1, fn _el ->
      Enum.random([{:pickaxe}, {:axe}]) |> space_out
      Process.sleep(5000)
    end)

    smith()
  end
end

# Task.async(&NL.AgentPattern.woodcutter/0)
