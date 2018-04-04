defmodule Control do # {
  @moduledoc """
  Documentation for Control.
  """

  def controlling(leader\\0, agents\\0, num_plays\\0, plays\\nil)

  def controlling(leader, agents, num_plays, plays) do
    #IO.puts "#{Node.self()} => controlling(#{leader}, #{agents}, #{num_plays}, plays)"
    receive do
      {:leader, theLeader} ->
        controlling(theLeader, agents, num_plays, plays)
      {:add, aPlay} ->
        IO.puts "controlling.add"
        #case rem(num_plays, 100000) do
        #  0 -> IO.write "#{num_plays}\r"
        #  _ -> nil
        #end
        score = Bridge.score_hand(aPlay, 0)
        #IO.puts " score = #{score}"
        new_plays = Bridge.add_to_play(leader, {score, aPlay}, plays)
        controlling(leader, agents, num_plays + 1, new_plays)
      {:DOWN, _, _, _, _} ->
        IO.puts "end #{agents}"
        controlling(leader, agents - 1, num_plays, plays)
      {:starter, function, args} ->
        IO.puts "start #{Node.self()} #{agents}"
        spawn_monitor(Bridge, function, args)
        controlling(leader, agents + 1, num_plays, plays)
      {:do} ->
        IO.puts "controlling do #{inspect self()}"
        Bridge.do_one()
        controlling(leader, agents, num_plays, plays)
      {msg} ->
        IO.puts "got msg?"
        IO.inspect msg
    end
  end
end # }
