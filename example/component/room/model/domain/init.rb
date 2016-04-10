class Component::Room::Domain

  extend Memoist
  # @param room [Component::Room]
  def initialize(room)
    @room = room
  end

  def algorithm
    @room.algorithm.new
  end

  # @param com_card [Fixnum]
  def selected_card(com_card)
    algorithm
      .decide(@room.game, com_card)
  end
  memoize(:selected_card)

  # @param player_card [Fixnum]
  # @param com_card [Fixnum]
  def play(player_card, com_card)
    @room
      .game
      .duel(selected_card(com_card), player_card, com_card)
  end

end
