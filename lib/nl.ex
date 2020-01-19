defmodule NL do
  @moduledoc """
  Documentation for NL.
  """

  @doc """

  """
  def test do
    Task.async(&NL.AgentPattern.woodcutter/0)
    Task.async(&NL.AgentPattern.miner/0)
    Task.async(&NL.AgentPattern.smith/0)
    :ok
  end
end
