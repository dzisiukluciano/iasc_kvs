defmodule KVServer do

  import Application
  
  def hello do
    :world
  end


  def put(key, value) do
    case [valid_key?(key), valid_value?(value)] do
       [true, true] ->
          call_worker(choose_worker(key), :put, [key, value])
       [false, true] ->
          {:error, {:bad_args, %{key: key}}}
       [true, false] ->
          {:error, {:bad_args, %{value: value}}}
       [false, false] ->
          {:error, {:bad_args, %{key: key, value: value}}}
    end
  end


  def get(key) do
    if valid_key?(key) do
      call_worker(choose_worker(key), :get, [key])
    else
      {:error, {:bad_args, %{key: key}}}
    end
  end


  def delete(key) do

    if valid_key?(key) do
      call_worker(choose_worker(key), :delete, [key])
    else
      {:error, {:bad_args, %{key: key}}}
    end

  end


  def values_gt(value) do
    if valid_value?(value) do
      call_all_workers({:values_gt, value})
    else
        {:error, {:bad_args, %{value: value}}}
    end
  end



  def values_lt(value) do
    if valid_value?(value) do
      call_all_workers({:values_lt, value})
    else
        {:error, {:bad_args, %{value: value}}}
    end
  end


  def keys() do
    call_all_workers({:keys})
  end


  def values() do
    call_all_workers({:values})
  end

  def size() do
    call_all_workers({:size})
  end
  

  defp call_worker(worker, func, args) do

    try do
      apply(KVWorker, func, [worker|args])
    catch
       (:exit, {reason, _}) -> {:error, reason}
       (:error, {reason, _}) -> {:error, reason}
       (:error, reason) -> {:error, reason}
       (type, data) -> {:error, {type, inspect(data)}}
    end

  end

  defp call_all_workers(msg) do
    all_workers_do(msg)
      |> build_response()
  end

  defp build_response({[r|replies], []}) do
    {:ok, collect([r|replies])}
  end

  defp build_response({_, [f|fnodes]}) do
    {:error, {:failed_nodes, [f|fnodes]}}
  end

  defp collect(replies) do
    replies
      |> Enum.map(fn({_, {:ok, sublist}}) -> sublist end)
      |> List.flatten()
  end

  defp all_workers_do(msg) do
    GenServer.multi_call(datanodes(), remote_worker_name(), msg)
  end

  defp valid_key?(key) do
    is_binary(key) and (byte_size(key) <= max_key_size())
  end

  defp valid_value?(value) do
    is_binary(value) and (byte_size(value) <= max_value_size())
  end

  defp choose_worker(key) do
    Enum.at(all_workers(), :erlang.phash2(key, length(all_workers())))
  end

  defp all_workers() do
    Enum.map(datanodes(), fn(dn) -> {remote_worker_name(), dn} end)
  end

  defp remote_worker_name() do
    get_env(:kv_server, :remote_worker_name)
  end

  defp datanodes() do
    get_env(:kv_server, :datanodes)
  end

  defp max_key_size() do
    get_env(:kv_server, :max_key_size)
  end

  defp max_value_size() do
    get_env(:kv_server, :max_value_size)
  end

end
