module RushGame::Algorithm
end
class RushGame::Algorithm::Base
  class << self
    # @param algorithm [Symbol]
    def derive(algorithm)
      RushGame::Algorithm::Deterministic
    end
  end

  # @param com_card [Fixnum]
  # @param game_state [RushGame::Rush]
  def decide(com_card, game_state)
    raise NotImplementedError
  end

end

class RushGame::Algorithm::Deterministic

  # @param com_card [Fixnum]
  # @param game_state [RushGame::Rush]
  def decide(game_state, com_card, n = 10000)
    chances = game_state.simulation_statistics(com_card, n)
    maximum_win_rate = chances.map(&:win_rate).max
    chances.select{|win_rate| win_rate.win_rate == maximum_win_rate}
      .shuffle
      .first
      .card
  end

end

class RushGame::Algorithm::Bayesian
  def decide(com_card, game_state, n = 10000)
    # TODO
  end
end

class RushGame::Algorithm::Roulette
  # @param com_card [Fixnum]
  # @param game_state [RushGame::Rush]
  def decide(com_card, game_state, n = 10000)
    # TODO
  end
end
