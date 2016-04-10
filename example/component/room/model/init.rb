class Component::Room
  extend Memoist

  class RoomNotInitialized < ERR::NotFound404;
    def self.error_id
      1
    end
  end

  class << self
    def initialize!
      @rooms = {}
    end

    def retrieve(room_id)
      Maybe
        .from_value(@rooms[room_id])
        .value{ raise RoomNotInitialized }
    end

    def register!(room_id, room)
      @rooms[room_id] = room
      removeables = @rooms.select{|k, v| v.creation_date < 1.day.ago}
      removeables.each{|k| @rooms.remove(k) }
    end

  end

  attr_reader(:algorithm, :com, :ai, :challenger, :game, :com_card, :id, :creation_date, :see_through)
  # @param algorithm [Symbol]
  # @param algorithm values: [:deterministic, :slightly_random, :roulette, :random, :always_win]
  def initialize(algorithm, game = nil, see_through = :true)
    @algorithm = RushGame::Algorithm::Base.derive(algorithm)
    @creation_date = DateTime.now.utc
    com = RushGame::Player.new("COM")
    ai = RushGame::Player.new("AI")
    challenger = RushGame::Player.new("Player")
    @game = game.nil? ? RushGame::Game.new(ai, challenger, com) : game
    @id = SecureRandom::urlsafe_base64(8)
    @see_through = see_through == :true
    freeze_com_card!
    decide_selected_card_in_background
    Component::Room::register!(@id, self)
  end

  def algorithm_name
    @algorithm.name
  end

  def decide_selected_card_in_background
    Concurrent::Future.execute do
      @locked = true
      domain.selected_card(@com_card)
      @locked = false
    end
  end

  def freeze_com_card!
    @com_card = @game.com.random_card
  end

  # @param card_id [Fixnum] the card available for the player
  def play!(card_id)
    return self if @locked
    game = domain.play(card_id, @com_card)
    Component::Room.new(@algorithm.symbol, game)
  end

  def ai
    @game.me
  end

  def challenger
    @game.him
  end

  def com
    @game.com
  end

  def storage
    @game.storage
  end

  def domain
    self.class::Domain.new(self)
  end
  memoize(:domain)

  initialize!
end
