class RushGame::AI
  extend Memoist
  attr_reader(:player, :algorithm)
  def initialize(player, algorithm)
    @player = player
    @algorithm = algorithm
  end

  def decision(game_state, com_card, n = 10000)
    @algorithm.decide(game_state, com_card, n)
  end
  memoize(:decision)

  def duel(opp_card, com_card, game_state)
    game_state = game_state.duel(decision(game_state, com_card), opp_card, com_card)
    RushGame::AI.new(game_state.me, @algorithm, game_state)
  end

end

RushGame::AI::Deterministic = RushGame::AI.new(
  RushGame::Player.new("Deterministic"),
  RushGame::Algorithm::Deterministic.new
)

RushGame::AI::Roulette = RushGame::AI.new(
  RushGame::Player.new("Roulette"),
  RushGame::Algorithm::Roulette.new
)

RushGame::AI::Deterministic2 = RushGame::AI.new(
  RushGame::Player.new("Deterministic2"),
  RushGame::Algorithm::Deterministic2.new
)

RushGame::AI::PureRandom= RushGame::AI.new(
  RushGame::Player.new("PureRandom"),
  RushGame::Algorithm::PureRandom.new
)


class RushGame::Simulation

  extend Memoist

  attr_reader(:ai1, :ai2, :game_state1, :game_state2)
  def initialize(ai1, ai2, game_state1, game_state2)
    @ai1 = ai1
    @ai2 = ai2
    @game_state1 = game_state1
    @game_state2 = game_state2
    @com_card = game_state1.com.random_card
  end

  def duel(silent = false)
#     puts "#{@ai1.player.name} #{@ai1.player.ammo.join(", ")}"
#     puts "#{@ai2.player.name} #{@ai2.player.ammo.join(", ")}"
#     puts "#{@ai1.player.name}(#{ai1decision}) VS #{ai2.player.name}(#{ai2decision})"
#     puts
    ai1state = @game_state1.duel(ai1decision, ai2decision, @com_card)
    ai2state = @game_state2.duel(ai2decision, ai1decision, @com_card)
    RushGame::Simulation.new(
      RushGame::AI.new(ai1state.me, @ai1.algorithm),
      RushGame::AI.new(ai2state.me, @ai2.algorithm),
      ai1state,
      ai2state
    )
  end
  memoize(:duel)

  def ai1decision
    @ai1.decision(@game_state1, @com_card)
  end
  memoize(:ai1decision)

  def ai2decision
    @ai2.decision(@game_state2, @com_card)
  end
  memoize(:ai2decision)

  class << self

    def initialize!
    @memo = {}
    end

    def simulate(n)
      (0..n - 1).map do |i|
        s = _simulation.duel.duel.duel.duel.duel.duel
        p1 = s.game_state1.me
        p2 = s.game_state2.me
        winner = if(p1.point > p2.point)
          p1.name
        elsif(p2.point > p1.point)
          p2.name
        else
          "draw"
        end
        @memo[winner] = Maybe.from_value(@memo[winner]).map{|x| x + 1}.value(1)
        puts @memo
        winner
      end
    end

    private def _simulation
      ai1 = RushGame::AI::Deterministic2
      ai2 = RushGame::AI::Deterministic
      com = RushGame::Player.new("COM")
      RushGame::Simulation.new(
        ai1,
        ai2,
        RushGame::Game.new(
          ai1.player,
          ai2.player,
          com,
          0
        ),
        RushGame::Game.new(
          ai2.player,
          ai1.player,
          com,
          0
        )
      )
    end
  end

  initialize!
end
