defmodule Rest do

  use Maru.Router
  
  require Logger

  @user_fail [:bad_args]

  before do

    plug Plug.Logger
    
    plug Plug.Parsers,
    pass: ["*/*"],
    parsers: [
      :urlencoded,
      :json,
      :multipart
    ]

  end

  namespace :entries do 
    
    route_param :key do

      get do
        json(conn, response(KVServer.get(params[:key])))
      end

      delete do
        json(conn, response(KVServer.delete(params[:key])))
      end

    end

    params do
      optional :values_gt, type: String
      optional :values_lt, type: String
      exactly_one_of [:values_gt, :values_lt]
    end
    get do
      json(conn, response(do_filter(params)))
    end
    
    params do
      requires :key, type: String
      requires :value, type: String
    end
    post do
      json(conn, response(KVServer.put(params[:key], params[:value])))
    end

  end


  namespace :size do 
    
    get do
      json(conn, response(KVServer.size()))
    end

  end

  rescue_from :all, as: e do
    json(conn, response({:error, {:other, inspect(e)}}))
  end
  
  
  defp do_filter(%{values_gt: value}) do
    KVServer.values_gt(value)
  end
  
  
  defp do_filter(%{values_lt: value}) do
    KVServer.values_lt(value)
  end
  
  
  defp response({:ok, data}) do 
    JSend.success(data)
  end 
  
  defp response({:error, {type, data}}) when type in @user_fail do 
    JSend.fail(%{type: type, data: data})
  end 
  
  defp response({:error, {type, data}}) do 
    JSend.error(%{type: type, data: data})
  end 

end


defmodule JSend do
  
  defstruct status: "", data: ""
  
  def success(data) do 
    %__MODULE__{status: "success", data: data}
  end
  
  def fail(data) do 
    %__MODULE__{status: "fail", data: data}
  end 
  
  def error(data_or_msg) do 
    %__MODULE__{status: "error", data: data_or_msg}
  end

end
