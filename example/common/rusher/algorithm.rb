module RushGame::Algorithm
end
class RushGame::Algorithm::Base
  module Symbols
    Deterministic = :deterministic
    Deterministic2 = :deterministic2
    Roulette = :roulette
    PureRandom = :purerandom
  end

  class << self
    # @param algorithm [Symbol]
    def derive(algorithm)
      # return RushGame::Algorithm::Counter
      return RushGame::Algorithm::Deterministic if algorithm == Symbols::Deterministic
      return RushGame::Algorithm::Deterministic2 if algorithm == Symbols::Deterministic2
      return RushGame::Algorithm::Roulette if algorithm == Symbols::Roulette
      return RushGame::Algorithm::PureRandom if algorithm == Symbols::PureRandom
    end
  end

  # @param com_card [Fixnum]
  # @param game_state [RushGame::Game]
  def decide(com_card, game_state)
    raise NotImplementedError
  end

end

class RushGame::Algorithm::Deterministic

  def self.symbol
    :deterministic
  end

  # @param com_card [Fixnum]
  # @param game_state [RushGame::Game]
  def decide(game_state, com_card, n = 10000)
    chances = game_state.simulation_statistics(com_card, n)
    maximum_win_rate = chances.map(&:win_rate).max
    chances.select{|win_rate| win_rate.win_rate == maximum_win_rate}
      .shuffle
      .first
      .card
  end

end

class RushGame::Algorithm::InverseDeterministic

  def self.symbol
    :"???"
  end

  # @param com_card [Fixnum]
  # @param game_statee [RushGame::Game]
  def decide(game_state, com_card, n = 10000)
    me = game_state.me
    him = game_state.him
    com = game_state.com
    storage = game_state.storage
    simulator = RushGame::Game.new(him, me, com, storage)
    expected_opp_card = RushGame::Algorithm::Deterministic.new.decide(simulator, com_card)
    selected = (me.ammo + me.ammo).drop_while{|x| x < expected_opp_card}.take(2).last
    return me.ammo.first if selected.nil?
    return selected
  end

end

class RushGame::Algorithm::PureRandom
  def self.symbol
    :purerandom
  end

  def decide(game_state, com_card, n = 10000)
    game_state.me.ammo.shuffle.first
  end
end

class RushGame::Algorithm::Deterministic2

  def self.symbol
    :deterministic2
  end

  # @param com_card [FixNum]
  # @param game_state [RushGame::Game]
  def decide(game_state, com_card, n = 10000)
    chances = game_state.simulation_statistics(com_card, n)
    chances.sort_by(&:win_rate).reverse.take(2).shuffle.first.card
  end

end

class RushGame::Algorithm::Roulette

  def self.symbol
    :roulette
  end

  # @param com_card [Fixnum]
  # @param game_state [RushGame::Game]
  def decide(game_state, com_card, n = 10000)
    chances = game_state.simulation_statistics(com_card, n)
    probs = chances.map(&:win_rate).map{|x| x * x}
    totals = probs.sum
    # puts chances.map(&:card).zip(probs).map{|c, p| "#{c} => #{p}"}
    # puts
    val = Random.rand * totals
    chances
      .map(&:card)
      .zip(probs)
      .drop_while{|c, p| val -= p; val > 0}
      .first
      .first
  end
end
