module RushGame
end
class String
  def write
    puts self
  end
end

require File.expand_path("../winrate", __FILE__)
require File.expand_path("../player", __FILE__)
require File.expand_path("../rush", __FILE__)
require File.expand_path("../algorithm", __FILE__)
require File.expand_path("../simulation", __FILE__)

# P1 = Player.new("AI")
# P2 = Player.new("Player")
# Com = Player.new("COM")
# Game = Rush.new(P1, P2, Com)

# g = Game
# Game.simulates(2, 5)
# require "pry"
# binding.pry
