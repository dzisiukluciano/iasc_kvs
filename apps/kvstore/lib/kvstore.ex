defmodule KVS do
  @moduledoc """
  Documentation for KVS.
  """

  @doc """
  Hello world.

  ## Examples

      iex> KVS.hello
      :world

  """
  def hello do
    :world
  end


  def start_link do
    Task.start_link(fn -> loop(%{}) end)
  end

  defp loop(map) do
    receive do
      {:get, key, caller} ->
        send caller, Map.get(map, key)
        loop(map)
      {:put, key, value} ->
        loop(Map.put(map, key, value))
    end
  end
  
end
