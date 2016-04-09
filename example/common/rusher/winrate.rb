class RushGame::WinRate
  extend Memoist
  attr_reader(:card)
  def initialize(card, data)
    @data = data
    @card = card
  end

  def win_count
    @data.select{|x| x == 1}.count
  end
  memoize(:win_count)

  def lose_count
    @data.select{|x| x == -1}.count
  end
  memoize(:lose_count)

  def draw_count
    @data.select{|x| x == 0}.count
  end
  memoize(:draw_count)

  def win_rate
    return 10000 if win_count > 0 and lose_count == 0 # instant win
    return -1 if win_count == 0 and lose_count == 0 # draw
    return (100 * win_count.to_f / lose_count).to_i / 100.0
  end

  def message
    "win: #{win_count}, draw: #{draw_count}, lose: #{lose_count}, win:lose = #{win_rate}x"
  end

end
