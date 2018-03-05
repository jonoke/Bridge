defmodule Shapes do # {

  @moduledoc """
  Shapes routines to categorize hand shapes
  """

  @doc """
  Hello world.

  ## Examples

      iex> Bridge.hello
      :world

  """
  def hello do
    :world
  end

  def distribution(list) do
    MapSet.new(
      for a <- list,
	  b <- List.delete(list, a),
	  c <- List.delete(List.delete(list, a), b),
	  d <- List.delete(List.delete(List.delete(list, a), b), c)
      do
	[a, b, c, d]
      end
    )
  end
  @flat [4, 3, 3, 3]
  @flatSet MapSet.new(
      for a <- @flat,
	  b <- List.delete(@flat, a),
	  c <- List.delete(List.delete(@flat, a), b),
	  d <- List.delete(List.delete(List.delete(@flat, a), b), c)
      do
	[a, b, c, d]
      end
    )
  def flat, do: @flatSet

  def flat?(seat) do
    case seat do
      { _hand, {_hcp, _lpt, _ltc, shape}} ->
	MapSet.member?(flat(), shape)
    end
  end

  @bal44 [4, 4, 3, 2]
  @bal44Set MapSet.new(
      for a <- @bal44,
	  b <- List.delete(@bal44, a),
	  c <- List.delete(List.delete(@bal44, a), b),
	  d <- List.delete(List.delete(List.delete(@bal44, a), b), c)
      do
	[a, b, c, d]
      end
    )
  @bal53 [5, 3, 3, 2]
  @bal53Set MapSet.new(
      for a <- @bal53,
	  b <- List.delete(@bal53, a),
	  c <- List.delete(List.delete(@bal53, a), b),
	  d <- List.delete(List.delete(List.delete(@bal53, a), b), c)
      do
	[a, b, c, d]
      end
    )
  @balanced MapSet.union(
    @flatSet,
    MapSet.union(@bal44Set, @bal53Set)
  )
  def balanced, do: @balanced
  def balanced?(seat) do
    case seat do
      { _hand, {_hcp, _lpt, _ltc, shape}} ->
	MapSet.member?(balanced(), shape)
    end
  end
  @sem54 [5, 4, 2, 2]
  @sem54Set MapSet.new(
      for a <- @sem54,
	  b <- List.delete(@sem54, a),
	  c <- List.delete(List.delete(@sem54, a), b),
	  d <- List.delete(List.delete(List.delete(@sem54, a), b), c)
      do
	[a, b, c, d]
      end
    )
  @sem63 [6, 3, 2, 2]
  @sem63Set MapSet.new(
      for a <- @sem63,
	  b <- List.delete(@sem63, a),
	  c <- List.delete(List.delete(@sem63, a), b),
	  d <- List.delete(List.delete(List.delete(@sem63, a), b), c)
      do
	[a, b, c, d]
      end
    )
  @semibal MapSet.union(
    @sem54Set,
    @sem63Set
  )
  def semibal, do: @semibal
  def semibal?(seat) do
    case seat do
      { _hand, {_hcp, _lpt, _ltc, shape}} ->
	MapSet.member?(semibal(), shape)
    end
  end
  def unbal?(seat) do
    not (balanced?(seat) or semibal?(seat))
  end
end # }
