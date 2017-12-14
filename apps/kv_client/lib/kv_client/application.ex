defmodule KVS do

  use Application

  def start(_type, _args) do
    KVClient.Supervisor.start_link
  end
 

  def get(key) do
    GenServer.call(KVClient, {:get, key})
  end

  def put(key, value) do
    GenServer.call(KVClient, {:put, key, value})
  end

  def delete(key) do
    GenServer.call(KVClient, {:delete, key})
  end

  def gt(value) do
    GenServer.call(KVClient, {:gt, value})
  end

  def lt(value) do
    GenServer.call(KVClient, {:lt, value})
  end

  def size() do
    GenServer.call(KVClient, {:size})
  end

end
