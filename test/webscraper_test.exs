defmodule WebscraperTest do
  use ExUnit.Case
  doctest Webscraper

  test "greets the world" do
    assert Webscraper.hello() == :world
  end
end
