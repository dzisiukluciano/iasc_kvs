defmodule KVClient do
  
  use GenServer
  require Logger

  def hello do
    :world
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:get, key}, _from, state) do
    response = HTTPotion.get("http://127.0.0.1:8888/entries/#{key}")
    Logger.info(~s(#{response.body}))
    {:reply, response.body, state}
  end

  def handle_call({:put, key, value}, _from, state) do
    response = HTTPotion.post("http://127.0.0.1:8888/entries?key=#{key}&value=#{value}")
    Logger.info(~s(#{response.body}))
    {:reply, response.body, state}
  end

  def handle_call({:delete, key}, _from, state) do
    response = HTTPotion.delete("http://127.0.0.1:8888/entries/#{key}")
    Logger.info(~s(#{response.body}))
    {:reply, response.body, state}
  end

  def handle_call({:gt, value}, _from, state) do
    response = HTTPotion.get("http://127.0.0.1:8888/entries?values_gt=#{value}")
    Logger.info(~s(#{response.body}))
    {:reply, response.body, state}
  end

  def handle_call({:lt, value}, _from, state) do
    response = HTTPotion.get("http://127.0.0.1:8888/entries?values_lt=#{value}")
    Logger.info(~s(#{response.body}))
    {:reply, response.body, state}
  end
  
  def handle_call({:size}, _from, state) do
    response = HTTPotion.get("http://127.0.0.1:8888/size")
    Logger.info(~s(#{response.body}))
    {:reply, response.body, state}
  end


end
