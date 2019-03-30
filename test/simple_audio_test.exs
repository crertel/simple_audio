defmodule SimpleAudioTest do
  use ExUnit.Case
  doctest SimpleAudio

  test "greets the world" do
    assert SimpleAudio.hello() == :world
  end
end
