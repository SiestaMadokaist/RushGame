class Player

  OriginalAmmo = [1,2,3,4,5,6]

  class ErrInvalidCard < StandardError; end

  attr_reader(:name, :ammo, :point)
  def initialize(name, ammo = OriginalAmmo, point = 0)
    @name = name
    @ammo = ammo
    @point = point
  end

  def validate_use_of!(my_card)
    raise ErrInvalidCard, "Player: #{@name} trying to use #{my_card}" unless @ammo.include?(my_card)
  end

  def win(my_card, his_card, com_card, storage)
    validate_use_of!(my_card)
    ammo = @ammo.select{|x| x != my_card}
    point = my_card + his_card + com_card + storage + @point
    Player.new(@name, ammo, point)
  end

  def lose(my_card)
    validate_use_of!(my_card)
    ammo = @ammo.select{|x| x != my_card}
    Player.new(@name, ammo, @point)
  end

  def random_card
    @ammo.shuffle.first
  end
end

class Rush

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
      Rush.new(@me.win(my_card, his_card, com_card, @storage), @him.lose(his_card), @com.lose(com_card), 0)
    elsif(my_card < his_card)
      Rush.new(@me.lose(my_card), @him.win(his_card, my_card, com_card, @storage), @com.lose(com_card), 0)
    else
      new_stores = @storage + my_card + his_card + com_card
      Rush.new(@me.lose(my_card), @him.lose(his_card), @com.lose(com_card), new_stores)
    end
  end

  def validate_final!
    total_point = @me.point + @him.point + @com.point + @storage
    raise SomethingWentWrongDuringSimulation if total_point != 63
  end

  def simulates(my_card, com_card, n = 10)
    (0..n).map{|i| unsafe_simulation(my_card, com_card)}
  end

  def simulate_all(com_card, n = 10000)
    results = @me.ammo.map{|card| simulates(card, com_card, n)}
    messages = results.map do |result|
      win_count = result.select{|x| x == 1}.count
      lose_count = result.select{|x| x == -1}.count
      draw_count = result.select{|x| x == 0}.count
      begin
        win_rate = (100 * win_count.to_f / lose_count).to_i / 100.0
      rescue FloatDomainError
        win_rate = "InstantWin"
      end
      "win: #{win_count}, draw: #{draw_count}, lose: #{lose_count}, win:lose = #{win_rate}x"
    end
    @me.ammo.zip(messages).map{|p, m| "#{p}: #{m}"}.join("\n")
  end

  # def statistics(com_card, n = 10)
    # rc = @com.ammo.select{|x| x != com_card}.shuffle.first
    # test = @me
      # .ammo
      # .map do |x|
      # d = duel(x, @him.random_card, com_card)
      # result = d.simulate_all(rc, n)
    # end
    # test.join("\n\n")
  # end

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

class String
  def write
    puts self
  end
end

P1 = Player.new("AI")
P2 = Player.new("Player")
Com = Player.new("COM")
Game = Rush.new(P1, P2, Com)

g = Game
# Game.simulates(2, 5)
require "pry"
binding.pry
