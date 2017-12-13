defmodule KVWorker do

  def hello do
    :world
  end

  @compile {:parse_transform, :ms_transform}

  use GenServer

  require Logger

  ## client api

  def start_link(entries, max_entry_count) do
    GenServer.start_link(__MODULE__, [entries, max_entry_count], [name: :data_worker])
  end

  def put(worker, key, value)  do
    GenServer.call(worker, {:put, key, value})
  end

  def get(worker, key) do
    GenServer.call(worker, {:get, key})
  end

  def delete(worker, key) do
    GenServer.call(worker, {:delete, key})
  end

  ## server callbacks

  ## siempre devuelve {:ok, state}
  def init([entries, max_entry_count]) do
    {:ok, {entries, max_entry_count}}
  end

  def handle_call({:put, key, value}, _, {entries, max_entry_count} = state) do

    unless full?({entries, max_entry_count}) do
      :ets.insert(entries , {key, value})
      {:reply, {:ok, %{key: key, value: value, node: node()}}, state}
    else
      {:reply,{:error,{:no_space, %{node: node(), entries: entry_count(entries)}}}, state}
    end

  end

  def handle_call({:get, key}, _, {entries, _max_entry_count} = state) do

    case lookup(entries, key) do
      {:ok, value} ->
        {:reply, {:ok, %{key: key, value: value, node: node()}}, state}
      :error ->
        {:reply, {:error, {:key_not_found, %{key: key}}}, state}
    end

  end

  def handle_call({:delete, key}, _,  {entries, _max_entry_count} = state) do
    case lookup(entries, key) do
      {:ok, _} ->
        :ets.delete(entries, key)
        {:reply, {:ok, %{key: key, node: node()}}, state}
      :error ->
        {:reply, {:error, {:key_not_found, %{key: key}}}, state}
    end
  end

  def handle_call({:keys}, _, {entries, _max_entry_count} = state) do
    {:reply, {:ok, :ets.foldl(fn ({k,_v}, ks) -> [k|ks] end, [], entries)}, state}
  end

  def handle_call({:values}, _, {entries, _max_entry_count} = state) do
    {:reply, {:ok, :ets.foldl(fn({_k,v}, vs) -> [v|vs] end, [], entries)}, state}
  end

  def handle_call({:size}, _, {entries, _max_entry_count} = state) do
    {:reply, {:ok, %{node: node(), entries: entry_count(entries)}}, state}
  end

  def handle_call({:values_gt, value}, _, {entries, _max_entry_count} = state) do

    values = :ets.select(entries,
      :ets.fun2ms(fn({k,v}) when v > value -> v end))

    {:reply, {:ok, values}, state}

  end

  def handle_call({:values_gte, value}, _, {entries, _max_entry_count} = state) do

    values = :ets.select(entries,
      :ets.fun2ms(fn({k,v}) when v >= value -> v end))

    {:reply, {:ok, values}, state}

  end


  def handle_call({:values_lt, value}, _, {entries, _max_entry_count} = state) do

    values = :ets.select(entries,
      :ets.fun2ms(fn({k,v}) when v < value -> v end))

    {:reply, {:ok, values}, state}

  end

  def handle_call({:values_lte, value}, _, {entries, _max_entry_count} = state) do

    values = :ets.select(entries,
      :ets.fun2ms(fn({k,v}) when v <= value -> v end))

    {:reply, {:ok, values}, state}

  end

  def handle_info(msg, {_entries, _max_entry_count} = state) do
    Logger.info(~s(Message #{inspect msg} not understood :())
    {:noreply, {_entries, _max_entry_count} = state}
  end

  defp lookup(server, key) do
    case :ets.lookup(server, key) do
      [{^key, value}] -> {:ok, value}
      [] -> :error
    end
  end

  defp full?({entries, max_entry_count}) do
    not(entry_count(entries) < max_entry_count)
  end

  defp entry_count(entries) do
    :ets.info(entries, :size)
  end


end
