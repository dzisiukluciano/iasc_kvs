defmodule KVWorkerTest do
  use ExUnit.Case
  doctest KVWorker

  test "greets the world" do
    assert KVWorker.hello() == :world
  end
end
