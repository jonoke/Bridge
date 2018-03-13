defmodule BridgeTest do
  use ExUnit.Case
  doctest Bridge

  :rand.seed(:exrop, {1, 2, 1})
  test "run hand" do
    x = Bridge.deal()
    Bridge.show(x)
    hand = Bridge.player(x, Bridge.spades(), Bridge.north())
    IO.puts "hand is #{length(hand)}"
    Bridge.showHands(Bridge.east(), hand)
    assert true
  end
end
