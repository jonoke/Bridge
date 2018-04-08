defmodule Control do # {
  @moduledoc """
  Documentation for Control.
  """

  def controlling(leader\\0, agents\\0, num_plays\\0, plays\\nil)

  def controlling(leader,    agents,    num_plays,    plays) do
#    IO.puts "#{Node.self()} => controlling(#{agents}, #{num_plays}, plays)"
    receive do
      {:add, aPlay} ->
        #IO.puts "controlling.add"
#        case rem(num_plays, 100000) do
#          0 -> IO.puts "#{num_plays}\r"
#          _ -> nil
#        end
        new_plays = Bridge.add_to_play(leader, aPlay, plays)
        controlling(leader, agents, num_plays + 1, new_plays)
      {:show, leader} ->
        {ns, plays} = plays
        IO.puts "Total = #{num_plays}"
        IO.puts "NS score = #{ns}"
        Bridge.showHand(leader, plays)
        controlling(leader, agents, num_plays, plays)
      {:DOWN, _, _, _, _} ->
        IO.puts "end #{Node.self()} #{agents}"
        IO.puts "#{Time.to_string(Time.utc_now())}
        controlling(leader, agents - 1, num_plays, plays)
      {:starter, function, args} ->
        IO.puts "start #{Node.self()} #{agents}"
        spawn_monitor(Bridge, function, args)
        controlling(leader, agents + 1, num_plays, plays)
      {:do, controls} ->
        IO.puts "controlling do #{inspect self()}"
        IO.inspect controls
        Bridge.do_one(controls)
        IO.puts ""
        controlling(leader, agents, num_plays, plays)
      {msg} ->
        IO.puts "got msg?"
        IO.inspect msg
        controlling(leader, agents, num_plays, plays)
    end
  end
  def setup(nodes, pids\\[])
  def setup([], pids) do
    Enum.reverse(pids)
  end
  def setup([hd|tl], pids) do
    case Node.connect(hd) do
      true ->
        IO.puts "Node.connect(#{hd}) is true"
        pid = Node.spawn(hd, Control, :controlling, [])
        IO.puts "node #{hd} pid = #{inspect(pid)}"
        setup(tl, [pid|pids])
      false ->
        IO.puts "node #{hd} no connect"
        setup(tl, pids)
    end
  end
  def do_one() do
    IO.puts "#{Time.to_string(Time.utc_now())}
    controls = [one] = setup([:one@arch])
    send one,{:do,controls}
  end
end # }
