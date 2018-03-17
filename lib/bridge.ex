defmodule Bridge do # {
  @moduledoc """
  Documentation for Bridge.
  """

  import Enum, only: [ reverse: 1 ]
  import :timer, only: [sleep: 1]

  def seats, do: { :North, :East, :South, :West }
  def suits, do: { :Clubs, :Diamonds, :Hearts, :Spades, :NoTrumps }
  def suits1, do: { :C, :D, :H, :S, :NT }
  def ranks, do: { 0, 0, 2, 3, 4, 5, 6, 7, 8, 9, :T, :J, :Q, :K, :A }

  @cl 0
  @di 1
  @he 2
  @sp 3
  @nt 4

  def clubs,    do: @cl
  def diamonds, do: @di
  def heart,    do: @he
  def spades,   do: @sp
  def notrumps, do: @nt
  
  @north 0
  @east  1
  @south 2
  @west  3

  def north, do: @north
  def east,  do: @east
  def south, do: @south
  def west,  do: @west

# 2 = 8
# 3 = 47
# 4 = 3023
# 5 = 110439
  @deck_size 5
  @deck for x <- 0..3, y <- 2..6, do: {x, y}

  #@deck_size 13
  #@deck for x <- 0..3, y <- 2..14, do: {x, y}

  def deck, do: @deck 

  def hcp({_,rank}), do: max(0, rank - 10)

  def slot(card, []), do: [card]
  def slot(card, [hd|tl]) when card > hd, do: [card|[hd|tl]]
  def slot(card, [hd|tl]), do: [hd|slot(card,tl)]

#  def split(card = {0,_}, {cl,di,he,sp}), do: {slot(card, cl),di,he,sp}
#  def split(card = {1,_}, {cl,di,he,sp}), do: {cl,slot(card, di),he,sp}
#  def split(card = {2,_}, {cl,di,he,sp}), do: {cl,di,slot(card, he),sp}
#  def split(card = {3,_}, {cl,di,he,sp}), do: {cl,di,he,slot(card, sp)}

  def dealer(shuffled, idx \\ 0, aDeal \\ [], aHand \\ {[], [], [], []}, hcp \\0, lc\\0, ld\\0, lh\\0, ls\\0)

  def dealer(shuffled, @deck_size, aDeal, aHand, hcp, lc, ld, lh, ls) do
    shape = [lc,ld,lh,ls]
    dealer(shuffled, 0, [{aHand, {hcp, lpt(aHand), ltc(aHand), shape}} | aDeal], {[],[],[],[]}, 0, 0, 0, 0, 0)
  end
  def dealer([], _, aDeal, _, _, _, _, _, _), do:
    aDeal
  def dealer([card={0,_}|tl], idx, aDeal, {cl,di,he,sp}, hcp, lc, ld, lh, ls), do:
    dealer(tl, idx + 1, aDeal, {slot(card, cl),di,he,sp}, hcp + hcp(card), lc+1, ld, lh, ls)
  def dealer([card={1,_}|tl], idx, aDeal, {cl,di,he,sp}, hcp, lc, ld, lh, ls), do:
    dealer(tl, idx + 1, aDeal, {cl,slot(card, di),he,sp}, hcp + hcp(card), lc, ld+1,lh, ls)
  def dealer([card={2,_}|tl], idx, aDeal, {cl,di,he,sp}, hcp, lc, ld, lh, ls), do:
    dealer(tl, idx + 1, aDeal, {cl,di,slot(card, he),sp}, hcp + hcp(card), lc, ld, lh+1,ls)
  def dealer([card={3,_}|tl], idx, aDeal, {cl,di,he,sp}, hcp, lc, ld, lh, ls), do:
    dealer(tl, idx + 1, aDeal, {cl,di,he,slot(card, sp)}, hcp + hcp(card), lc, ld, lh, ls+1)

  def deal, do: dealer(Enum.shuffle(deck()))

  def cardStr({s, r}), do: "#{elem(suits1(),s)}#{elem(ranks(),r)}"
  def suitStr(s), do: "#{elem(suits(),s)}"
  def seatStr(s), do: "#{elem(seats(),s)}"

  def ltc({cl,di,he,sp}), do:
    ltc_suit(cl) + ltc_suit(di) + ltc_suit(he) + ltc_suit(sp)

  def lpt({cl,di,he,sp}), do:
    max(length(cl) - 4, 0) + max(length(di) - 4, 0) + max(length(he) - 4, 0) + max(length((sp)) -4, 0)

  def ltc_suit([]), do: 0
  def ltc_suit([{_, 14}]), do: 0
  def ltc_suit([{_, _}]), do: 1

  def ltc_suit([{_, 14}, {_, 13}]), do: 0
  def ltc_suit([{_, 14}, {_,  _}]), do: 1
  def ltc_suit([{_, 13}, {_,  _}]), do: 1
  def ltc_suit([{_,  _}, {_,  _}]), do: 2

  def ltc_suit([{_, 14}, {_, 13}, {_, 12}| _]), do: 0
  def ltc_suit([{_, 14}, {_, 13}, {_,  _}| _]), do: 1
  def ltc_suit([{_, 14}, {_, 12}, {_,  _}| _]), do: 1
  def ltc_suit([{_, 13}, {_, 12}, {_,  _}| _]), do: 1
  def ltc_suit([{_, 14}, {_,  _}, {_,  _}| _]), do: 2
  def ltc_suit([{_, 13}, {_,  _}, {_,  _}| _]), do: 2
  def ltc_suit([{_, 12}, {_,  _}, {_,  _}| _]), do: 2
  def ltc_suit([{_,  _}, {_,  _}, {_,  _}| _]), do: 3

  def showCard(rank) when rank < 10, do: IO.write "#{rank} "
  def showCard(rank), do: IO.write "#{elem(ranks(),rank)} "

  def showSuit([{_,rank}|rest]) do
    showCard(rank)
    showSuit(rest)
  end
  def showSuit([]), do: IO.puts ""
  def showSuits(_hand = {{c,d,h,s},{hcp,lpt,ltc,[lc,ld,lh,ls]}}) do
    IO.write "  C: "
    showSuit(c)
    IO.write "  D: "
    showSuit(d)
    IO.write "  H: "
    showSuit(h)
    IO.write "  S: "
    showSuit(s)

    IO.puts "hcp: #{hcp}  lpt: #{lpt}  ltc: #{ltc} #{ls}=#{lh}=#{ld}=#{lc}"
#    IO.puts " flat: #{Shapes.flat?(hand)}"
#    IO.puts "bal'd: #{Shapes.balanced?(hand)}"
#    IO.puts "sem-b: #{Shapes.semibal?(hand)}"
#    IO.puts "unbal: #{Shapes.unbal?(hand)}"
    IO.puts "-----"
  end

  def show([n,e,s,w]) do
    IO.puts "North: "
    showSuits(n)
    IO.puts "East: "
    showSuits(e)
    IO.puts "South: "
    showSuits(s)
    IO.puts "West: "
    showSuits(w)
  end

  def flat?([n,_e,_s,_w]) do
    Shapes.flat?(n)
  end
  def balanced?([n,_e,_s,_w]) do
    Shapes.balanced?(n)
  end
  def semi_bal?([n,_e,_s,_w]) do
    Shapes.semibal?(n)
  end
  def unbalanced?([n,_e,_s,_w]) do
    Shapes.unbal?(n)
  end
  def all_bal?([n,e,s,w]) do
    Shapes.balanced?(n) and Shapes.balanced?(s) and Shapes.balanced?(e) and Shapes.balanced?(w)
  end
  def unbal_more_one?([n,e,s,w]) do
    Shapes.unbal?(n) or Shapes.unbal?(s) or Shapes.unbal?(e) or Shapes.unbal?(w)
  end
  def unbal_more_two?([n,e,s,w]) do
    Shapes.unbal?(n) and Shapes.unbal?(s) and Shapes.unbal?(e)
    or
    Shapes.unbal?(n) and Shapes.unbal?(s) and Shapes.unbal?(w)
    or
    Shapes.unbal?(s) and Shapes.unbal?(e) and Shapes.unbal?(w)
  end
  def unbal_plus_unbal?([n,e,s,w]) do
    Shapes.unbal?(n) and (Shapes.unbal?(s) or Shapes.unbal?(e) or Shapes.unbal?(w))
  end
  def counter(n, check, count \\ 0)
  def counter(0, _, count), do: count
  def counter(n, check, count) do
    aDeal = deal()
    match = case check.(aDeal) do
      true -> 1
      false -> 0
    end
    counter(n - 1, check, count + match)
  end

  def count(n, count \\ 0)
  def count(0, count), do: count
  def count(n, count) do
    _aDeal = deal()
    count(n - 1, count + 1)
  end

  def playable(@nt, {cl,di,he,sp}), do: cl ++ di ++ he ++ sp

  def playable(@cl, {[],di,he,sp}), do: di ++ he ++ sp
  def playable(@cl, {cl,_d,_h,_s}), do: cl

  def playable(@di, {cl,[],he,sp}), do: cl ++ he ++ sp
  def playable(@di, {_c,di,_h,_s}), do: di

  def playable(@he, {cl,di,[],sp}), do: cl ++ di ++ sp
  def playable(@he, {_c,_d,he,_s}), do: he

  def playable(@sp, {cl,di,he,[]}), do: cl ++ di ++ he
  def playable(@sp, {_c,_d,_h,sp}), do: sp

  def remove_card({cl,di,he,sp}, card = {@cl, _}), do: {List.delete(cl,card),di,he,sp}
  def remove_card({cl,di,he,sp}, card = {@di, _}), do: {cl,List.delete(di,card),he,sp}
  def remove_card({cl,di,he,sp}, card = {@he, _}), do: {cl,di,List.delete(he,card),sp}
  def remove_card({cl,di,he,sp}, card = {@sp, _}), do: {cl,di,he,List.delete(sp,card)}

  def show_cards([]), do: IO.write " - "
  def show_cards([hd|tl]) do
    IO.write cardStr(hd)
    IO.write " "
    show_cards(tl)
  end

  def wins(trumps, played, winning \\ nil, pos \\ 0, who \\ 0)
  def wins(_trumps, [], winner, _pos, who), do: {winner, who}
  def wins(trumps, [hd|tl], nil, pos, who), do: wins(trumps, tl, hd, pos + 1, who)
  def wins(trumps, [try = {try_suit,try_rank}|tl], winner = {win_suit, win_rank}, pos, who), do: (
    cond do
      try_suit == win_suit && try_rank > win_rank -> wins(trumps, tl, try, pos + 1, pos)
      try_suit != win_suit && try_suit == trumps -> wins(trumps, tl, try, pos + 1, pos)
      true -> wins(trumps, tl, winner, pos + 1, who)
    end
  )

  def spawner(gather, function, args) do
    #IO.puts "spawner"
    send gather, {:start}
    spawn_monitor(Bridge, function, args)
    receive do
      _msg ->
        #IO.puts "spawner got #{inspect msg}"
        send gather, {:end}
    end
  end
  def getResults(gather) do
    #IO.puts "getResults"
    #sleep 200
    send gather, {:agents, self()}
    receive do
      {:agents, running} ->
        #IO.puts "getResults got :agents #{running}"
        cond do
          running = 0 ->
            #IO.puts "   got running = 0"
            send gather, {:give, self()}
            getResults(gather)
          true ->
            #IO.puts "getResults #{running} running"
            sleep 500
            send gather, {:agents, self()}
            getResults(gather)
        end
      {:give, results} ->
        #IO.puts "getResults got :give"
        results
    end
  end
  def gathering(agents\\0, plays\\[]) do
    receive do
      {:start} ->
        #IO.puts "start #{agents}"
        gathering(agents + 1, plays)
      {:end} ->
        #IO.puts "end #{agents}"
        gathering(agents - 1, plays)
      {:agents, sender} ->
        #IO.puts "gathering got :agents"
        send sender, {:agents, agents}
        gathering(agents, plays)
      {:add, aPlay} ->
        #IO.puts "gathering.add"
        gathering(agents, [aPlay|plays])
      {:give, sender} ->
        #IO.puts "gathering got give"
        send sender, {:give, plays}
        gathering(agents, plays)
    end
  end

  #
  # rotate h1 - h4 relative to winner
  # 
  def play_winner(gather, h1, h2, h3, h4, trumps, leader, winner, round, hand) when winner == leader do
    play(gather, h1, h2, h3, h4, trumps, winner, nil, round, @nt, 0, hand, [])
  end
  def play_winner(gather, h1, h2, h3, h4, trumps, leader, winner, round, hand) when winner > leader do
    play_winner(gather, h2, h3, h4, h1, trumps, leader + 1, winner, round, hand)
  end
  def play_winner(gather, h1, h2, h3, h4, trumps, leader, winner, round, hand) when leader > winner do
    play_winner(gather, h4, h1, h2, h3, trumps, leader - 1, winner, round, hand)
  end

  #
  # template
  #

  def play(gather, h1, h2, h3, h4, trumps, leader, playable\\nil, round\\0, lead_suit\\@nt, position\\0, hand\\[], played\\[])

  #
  # end of play ... return reversed play
  # 
  def play(gather, _h1, _h2, _h3, _h4, _trumps, _leader, _playable, @deck_size, _lead_suit, _position, hand, _played) do
    send gather, {:add, reverse(hand)}
  end

  #
  # end of one round
  #
  def play(gather, h1, h2, h3, h4, trumps, leader, _playable, round, _lead_suit, 4, hand, played) do # {
    played = reverse(played)
    {_card, winner} = wins(trumps, played)
    winner = rem(leader + winner, 4)
    play_winner(gather, h1, h2, h3, h4, trumps, leader, winner, round + 1, [{winner, played} | hand])
  end # }

  #
  # what is this ... ??
  #
  def play(_gather, _h1, _h2, _h3, _h4, _trumps, _leader, [], _round, _lead_suit, _position, _hand, _played), do: nil

  #
  # When playable is nil it means get list of playable cards appropriate to the card lead (= @nt if this is the lead)
  #
  def play(gather, h1, h2, h3, h4, trumps, leader, nil, round, lead_suit, position, hand, played) do # {
    play(gather, h1, h2, h3, h4, trumps, leader, playable(lead_suit, h1), round, lead_suit, position, hand, played)
  end # }

  #
  # Lead a card
  #
  def play(gather, h1, h2, h3, h4, trumps, leader, [card|rest], round, @nt, position, hand, played) do # {
    {lead_suit, _} = card
    new_h1 = remove_card(h1, card)
    #play(gather, h2, h3, h4, new_h1, trumps, leader, nil, round, lead_suit, position + 1, hand, [card|played])
    spawner(gather, :play, [gather, h2, h3, h4, new_h1, trumps, leader, nil, round, lead_suit, position + 1, hand, [card|played]])

    play(gather, h1, h2, h3, h4, trumps, leader, rest, round, @nt, position,     hand, played)
  end # }

  #
  # Play a card to a lead
  #
  def play(gather, h1, h2, h3, h4, trumps, leader, [card|rest], round, lead_suit, position, hand, played) do # {
    new_h1 = remove_card(h1, card)
    play(gather, h2, h3, h4, new_h1, trumps, leader, nil, round, lead_suit, position + 1, hand, [card|played])
    play(gather, h1, h2, h3, h4, trumps, leader, rest, round, lead_suit, position,     hand, played)
  end # }

  def player([{nh, _}, {eh, _}, {sh, _}, {wh, _}], trumps, declarer) do # {
    #
    # create a process to receive hand plays
    #
    gather = spawn(Bridge, :gathering, [])
    case declarer do
      @north -> play(gather, eh, sh, wh, nh, trumps, @east)
      @east  -> play(gather, sh, wh, nh, eh, trumps, @south)
      @south -> play(gather, wh, nh, eh, sh, trumps, @west)
      @west  -> play(gather, nh, eh, sh, wh, trumps, @north)
    end
    getResults(gather)
  end # }

  def showPlay([]), do: IO.write ") "
  def showPlay([card|rest]) do
    IO.write "#{cardStr(card)} "
    showPlay(rest)
  end

  def showHand(_, []), do: IO.puts "_"
  def showHand(leader, [{winner, rounds}|tl]) do
    IO.write "#{String.slice(seatStr(leader), 0..0)}("
    showPlay(rounds)
    showHand(winner, tl)
  end

  def showHands(leader, lst, n\\0)
  def showHands(_leader, [], n), do: IO.puts "Total #{n}"
  def showHands(leader, [hd|tl], n) do
    IO.write "#{n} "
    showHand(leader, hd)
    showHands(leader, tl, n + 1)
  end

  def do_one() do
    :rand.seed(:exrop, {1, 2, 3})
    hand =  deal()
    show(hand)
    {times, lists} = :timer.tc(fn -> player(hand, spades(), north()) end)
    IO.puts "that took #{times} with #{length(lists)} ways"
  end
end # }
