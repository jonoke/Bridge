defmodule Bridge do # {
  @moduledoc """
  Documentation for Bridge.
  """

  import Enum, only: [ reverse: 1 ]

  def seats,  do: { :North, :East, :South, :West }
  def suits,  do: { :Clubs, :Diamonds, :Hearts, :Spades, :NoTrumps }
  def suits1, do: { :C, :D, :H, :S, :NT }
  def ranks,  do: { 0, 0, 2, 3, 4, 5, 6, 7, 8, 9, :T, :J, :Q, :K, :A }

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

  @deck_size 3
  @deck for x <- 0..3, y <- 2..4, do: {x, y}

  #@deck_size 13
  #@deck for x <- 0..3, y <- 2..14, do: {x, y}

  def deck_size, do: @deck_size

  def deck, do: @deck 
  def hcp({_,rank}), do: max(0, rank - 10)

  def slot(card, []), do: [card]
  def slot(card, [hd|tl]) when card > hd, do: [card|[hd|tl]]
  def slot(card, [hd|tl]), do: [hd|slot(card,tl)]

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
#  def counter(n, check, count \\ 0)
#  def counter(0, _, count), do: count
#  def counter(n, check, count) do
#    aDeal = deal()
#    match = case check.(aDeal) do
#      true -> 1
#      false -> 0
#    end
#    counter(n - 1, check, count + match)
#  end

  def count(n, count \\ 0)
  def count(0, count), do: count
  def count(n, count) do
    _aDeal = deal()
    count(n - 1, count + 1)
  end

  def find_all_larger_than(_card, [], larger), do: larger
  def find_all_larger_than(card = {_, card_rank}, [hd|tl], larger) do
    case hd do
      {_, rank} when rank > card_rank -> find_all_larger_than(card, tl, [hd|larger])
      _ -> find_all_larger_than(card, tl, larger)
    end
  end

  def find_largest(_suit, [], card), do: card
  def find_largest(suit, [hd|tl], card = {_card_suit, card_rank}) do
    case hd do
      {^suit, rank} when rank > card_rank -> find_largest(suit, tl, hd)
      _ -> find_largest(suit, tl, card)
    end
  end

  def all_larger_and_smallest(suit, played, hand) do
#    IO.puts "all_larger(#{suitStr(suit)})"
#    IO.write "played "
#    IO.inspect played
#    IO.write "hand "
#    IO.inspect hand
    largest = find_largest(suit, played, {suit, 0})
#    IO.puts "largest = #{cardStr(largest)}"
    larger = find_all_larger_than(largest, hand, [])
#    IO.puts "find_all_larger "
#    IO.inspect larger
    [smallest|_] = Enum.reverse(hand)
    larger = cond do
      smallest < largest -> [smallest|larger]
      true -> larger
    end
#    IO.puts "all_larger_and_smallest "
#    IO.inspect larger
    larger
  end

  def smallest([]), do: []
  def smallest(list), do: Enum.at(Enum.reverse(list), 0)

  def smallest_of_each(a, b, c), do: List.flatten([smallest(a), smallest(b), smallest(c)])

  def all_and_smallest_of_each(all, a, b), do: List.flatten([all, smallest(a), smallest(b)])

  def playable(_trumps,@nt, {cl,di,he,sp}, _played), do: cl ++ di ++ he ++ sp

  def playable(@cl,@cl,{[],di,he,sp}, _played), do:         smallest_of_each(di,he,sp)
  def playable(@di,@cl,{[],di,he,sp}, _played), do: all_and_smallest_of_each(di,he,sp)
  def playable(@he,@cl,{[],di,he,sp}, _played), do: all_and_smallest_of_each(he,di,sp)
  def playable(@sp,@cl,{[],di,he,sp}, _played), do: all_and_smallest_of_each(sp,di,he)
  def playable(_,  @cl,{cl,_d,_h,_s},  played), do: all_larger_and_smallest(@cl, played, cl)

  def playable(@cl,@di,{cl,[],he,sp}, _played), do: all_and_smallest_of_each(cl,he,sp)
  def playable(@di,@di,{cl,[],he,sp}, _played), do:         smallest_of_each(cl,he,sp)
  def playable(@he,@di,{cl,[],he,sp}, _played), do: all_and_smallest_of_each(he,cl,sp)
  def playable(@sp,@di,{cl,[],he,sp}, _played), do: all_and_smallest_of_each(sp,cl,he)
  def playable(_,  @di,{_c,di,_h,_s},  played), do: all_larger_and_smallest(@di, played, di)

  def playable(@cl,@he,{cl,di,[],sp}, _played), do: all_and_smallest_of_each(cl,di,sp)
  def playable(@di,@he,{cl,di,[],sp}, _played), do: all_and_smallest_of_each(di,cl,sp)
  def playable(@he,@he,{cl,di,[],sp}, _played), do:         smallest_of_each(cl,di,sp)
  def playable(@sp,@he,{cl,di,[],sp}, _played), do: all_and_smallest_of_each(sp,cl,di)
  def playable(_,  @he,{_c,_d,he,_s},  played), do: all_larger_and_smallest(@he, played, he)

  def playable(@cl,@sp,{cl,di,he,[]}, _played), do: all_and_smallest_of_each(cl,di,he)
  def playable(@di,@sp,{cl,di,he,[]}, _played), do: all_and_smallest_of_each(di,cl,he)
  def playable(@he,@sp,{cl,di,he,[]}, _played), do: all_and_smallest_of_each(he,cl,di)
  def playable(@sp,@sp,{cl,di,he,[]}, _played), do:         smallest_of_each(cl,di,he)
  def playable(_,  @sp,{_c,_d,_h,sp},  played), do: all_larger_and_smallest(@sp, played, sp)

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

  def first_card_diff(leader, [{_a_win, [a_hd|_]}|_], [{_the_win, [the_hd|_]}|_]) when a_hd != the_hd do
    leader
  end
  def first_card_diff(leader, [{a_win, [a_hd|a_tl]}|a_rest], [{the_win, [the_hd|the_tl]}|the_rest]) when a_hd == the_hd do
    first_card_diff(rem(leader + 1, 4), [{a_win, a_tl}|a_rest], [{the_win, the_tl}|the_rest])
  end
  def first_card_diff(_leader, [{a_win, []}|a_rest], [{_the_win, []}|the_rest]) do
    first_card_diff(a_win, a_rest, the_rest)
  end

  def add_to_play(leader, first_one = {first_ns, first_play}, nil) do
    IO.write "first #{first_ns} "
    showHand(leader, first_play)
    first_one
  end

  def add_to_play(_leader, a_hand = {a_ns, _a_play}, _best_so_far = {best_ns, _best_play}) when a_ns == best_ns do
#    IO.write "same  #{best_ns} "
#    showHand(leader, a_play)
    a_hand
    #best_so_far
  end
  #
  # next result is different .. zipper for north/south
  #
  def add_to_play(leader, this_hand = {this_ns, this_play}, best_hand = {best_ns, best_play}) do
    first_diff = first_card_diff(leader, this_play, best_play)
    #IO.puts "best_result = #{best_ns} this_result = #{this_ns} first_diff = #{seatStr(first_diff)}"
    cond do
      this_ns > best_ns && (first_diff == @north || first_diff == @south) ->
#        IO.write "north #{this_ns} "
#        showHand(leader, this_play)
        this_hand
      this_ns < best_ns && (first_diff == @east || first_diff == @west) ->
#        IO.write "east  #{this_ns} "
#        showHand(leader, this_play)
        this_hand
      true ->
#        IO.write "keep  #{best_ns} "
#        showHand(leader, best_play)
        best_hand
    end
  end

  def score_hand([], n_s), do: n_s
  def score_hand([{@north, _play}|rest], n_s), do: score_hand(rest, n_s + 1)
  def score_hand([{@south, _play}|rest], n_s), do: score_hand(rest, n_s + 1)
  def score_hand([{_,      _play}|rest], n_s), do: score_hand(rest, n_s)


  #
  # rotate h1 - h4 relative to winner
  # 
  def play_winner(h1, h2, h3, h4, trumps, leader, winner, round, hand) when winner == leader do
    play(h1, h2, h3, h4, trumps, winner, nil, round, @nt, 0, hand, [])
  end
  def play_winner(h1, h2, h3, h4, trumps, leader, winner, round, hand) when winner > leader do
    play_winner(h2, h3, h4, h1, trumps, leader + 1, winner, round, hand)
  end
  def play_winner(h1, h2, h3, h4, trumps, leader, winner, round, hand) when leader > winner do
    play_winner(h4, h1, h2, h3, trumps, leader - 1, winner, round, hand)
  end

  def play1(h1, h2, h3, h4, trumps, leader) do
    IO.puts "play1 A"
    play2(h1, h2, h3, h4, trumps, leader, playable(trumps, @nt, h1, []), 0, @nt, 0, [], [])
  end

  def play2(_h1, _h2, _h3, _h4, _trumps, leader, [], _round, _lead_suit, _position, _hand, _played), do: (
    IO.puts "play2 B"
    nil
  )

  def play2(h1, h2, h3, h4, trumps, leader, [card = {lead_suit, _}|rest], round, @nt, position, hand, played) do # {
    IO.puts "play2 A #{inspect self()}"
    new_h1 = remove_card(h1, card)
    send self(), {:starter, :play, [h2, h3, h4, new_h1, trumps, leader, nil, 0, lead_suit, position + 1, hand, [card|played]]}
    #play(h2, h3, h4, new_h1, trumps, leader, nil, 0, lead_suit, position + 1, hand, [card|played])

    play2(h1, h2, h3, h4, trumps, leader, rest, round, @nt, position,     hand, played)
  end # }

  #
  # template
  #
  def play(h1, h2, h3, h4, trumps, leader, playable\\nil, round\\0, lead_suit\\@nt, position\\0, hand\\[], played\\[])

  #
  # end of play ... return reversed play
  # 
  def play(_h1, _h2, _h3, _h4, _trumps, _leader, _playable, @deck_size, _lead_suit, _position, hand, _played) do
    #IO.puts "play() before send :add"
    send self(), {:add, reverse(hand)}
  end

  #
  # end of one round
  #
  def play(h1, h2, h3, h4, trumps, leader, _playable, round, _lead_suit, 4, hand, played) do # {
    #IO.puts "play() end of one round"
    send self(), {:add, reverse(hand)}
    played = reverse(played)
    {_card, winner} = wins(trumps, played)
    winner = rem(leader + winner, 4)
    play_winner(h1, h2, h3, h4, trumps, leader, winner, round + 1, [{winner, played} | hand])
  end # }

  #
  # what is this ... the end of playing playable() cards
  #
  def play(_h1, _h2, _h3, _h4, _trumps, _leader, [], _round, _lead_suit, _position, _hand, _played), do: nil

  #
  # When playable is nil it means get list of playable cards appropriate to the card lead (= @nt if this is the lead)
  #
  def play(h1, h2, h3, h4, trumps, leader, nil, round, lead_suit, position, hand, played) do # {
    #IO.puts "play A #{round} #{position}"
    play(h1, h2, h3, h4, trumps, leader, playable(trumps, lead_suit, h1, played), round, lead_suit, position, hand, played)
  end # }

  #
  # Lead a card
  #
  def play(h1, h2, h3, h4, trumps, leader, [card|rest], round, @nt, position, hand, played) do # {
    {lead_suit, _} = card
    #IO.puts "play B #{round} #{position} #{cardStr(card)}"
    new_h1 = remove_card(h1, card)
    play(h2, h3, h4, new_h1, trumps, leader, nil, round, lead_suit, position + 1, hand, [card|played])

    play(h1, h2, h3, h4, trumps, leader, rest, round, @nt, position,     hand, played)
  end # }

  #
  # Play a card to a lead
  #
  def play(h1, h2, h3, h4, trumps, leader, [card|rest], round, lead_suit, position, hand, played) do # {
    #IO.puts "play C #{round} #{position} #{cardStr(card)}"
    new_h1 = remove_card(h1, card)
    play(h2, h3, h4, new_h1, trumps, leader, nil, round, lead_suit, position + 1, hand, [card|played])
    play(h1, h2, h3, h4, trumps, leader, rest, round, lead_suit, position,     hand, played)
  end # }

  def player([{nh, _}, {eh, _}, {sh, _}, {wh, _}], declarer, trumps) do # {
    #
    # create a process to receive hand plays
    #

    case declarer do
      @north -> play1(eh, sh, wh, nh, trumps, @east)
      @east  -> play1(sh, wh, nh, eh, trumps, @south)
      @south -> play1(wh, nh, eh, sh, trumps, @west)
      @west  -> play1(nh, eh, sh, wh, trumps, @north)
    end
    nil
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
    IO.puts "do_one()"
    :rand.seed(:exrop, {1, 2, 3})
    IO.puts "A"
    send self(), {:leader, @east}
    IO.puts "B"
    hand =  deal()
#    show(hand)
    {times, _value} = :timer.tc(fn -> player(hand, @north, @sp) end)
    IO.puts "that took #{times} "
#    IO.write "NS = #{ns} "
#    showHand(@east, play)
  end
end # }
