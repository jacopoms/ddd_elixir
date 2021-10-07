defmodule DddElixirTest do
  use ExUnit.Case
  doctest DddElixir

  test "greets the world" do
    assert DddElixir.hello() == :world
  end
end
