class RushGame::Player

  OriginalAmmo = [1,2,3,4,5,6]

  class ErrInvalidCard < StandardError; end

  attr_reader(:name, :ammo, :point)
  def initialize(name, ammo = OriginalAmmo, point = 0)
    @name = name
    @ammo = ammo
    @point = point
  end

  def validate_use_of!(my_card)
    raise ErrInvalidCard, "#{@name}: #{my_card} has already used" unless @ammo.include?(my_card)
  end

  def win(my_card, his_card, com_card, storage)
    validate_use_of!(my_card)
    ammo = @ammo.select{|x| x != my_card}
    point = my_card + his_card + com_card + storage + @point
    RushGame::Player.new(@name, ammo, point)
  end

  def lose(my_card)
    validate_use_of!(my_card)
    ammo = @ammo.select{|x| x != my_card}
    RushGame::Player.new(@name, ammo, @point)
  end

  def random_card
    @ammo.shuffle.first
  end
end
