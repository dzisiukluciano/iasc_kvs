defmodule KVSTest do
  use ExUnit.Case
  doctest KVS

  test "greets the world" do
    assert KVS.hello() == :world
  end
end
