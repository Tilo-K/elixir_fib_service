defmodule FibServiceTest do
  use ExUnit.Case
  doctest FibService

  test "greets the world" do
    assert FibService.hello() == :world
  end
end
