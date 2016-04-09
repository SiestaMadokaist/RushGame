class RushGame::Game

  extend Memoist
  attr_reader(:me, :him, :com, :storage)
  # @param mine [Player]
  # @param his [Player]
  # @param com [Player]
  # @param storage [Integer]
  # @param point_difference [Integer] differences between me and him
  def initialize(me, him, com, storage = 0)
    @me = me
    @him = him
    @com = com
    @storage = storage
  end

  # @param my_card [Integer]
  # @param his_card [Integer]
  # @param com_card [Integer]
  def duel(my_card, his_card, com_card)
    if(my_card > his_card)
      RushGame::Game.new(@me.win(my_card, his_card, com_card, @storage), @him.lose(his_card), @com.lose(com_card), 0)
    elsif(my_card < his_card)
      RushGame::Game.new(@me.lose(my_card), @him.win(his_card, my_card, com_card, @storage), @com.lose(com_card), 0)
    else
      new_stores = @storage + my_card + his_card + com_card
      RushGame::Game.new(@me.lose(my_card), @him.lose(his_card), @com.lose(com_card), new_stores)
    end
  end

  def validate_final!
    total_point = @me.point + @him.point + @com.point + @storage
    raise SomethingWentWrongDuringSimulation if total_point != 63
  end

  def simulates(my_card, com_card, n = 10)
    (0..n).map{|i| unsafe_simulation(my_card, com_card)}
  end

  def simulation_statistics(com_card, n = 10000)
    results = @me
      .ammo
      .map{|card| simulates(card, com_card, n)}
    @me.ammo.zip(results).map{|card, data| RushGame::WinRate.new(card, data)}
  end
  memoize(:simulation_statistics)

  def simulate_all(com_card, n = 10000)
    simulation_statistics.map(&:message)
  end

  protected
  # @param selected_com_card [Integer | NilClass]
  def unsafe_simulation(my_selected_card, selected_com_card)
    if(selected_com_card.nil?)
      validate_final!
      if(@me.point > @him.point)
        1
      elsif(@me.point < @him.point)
        -1
      else
        0
      end
    else
      @com.validate_use_of!(selected_com_card)
      my_card = my_selected_card
      his_card = @him.random_card
      rush = duel(my_card, his_card, selected_com_card)
      rush.unsafe_simulation(rush.me.random_card, rush.com.random_card)
    end
  end

end
