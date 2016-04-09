require File.expand_path("config/initializer/test_helper")
describe Component::Room::Domain do
  describe (".duel") do
    let(:room) {Component::Room.new(:deterministic)}
    it "does it correctly" do
      allow(room.domain).to(receive(:selected_card)).and_return(3)
      room_result = room.play(1, 3)
      expect(room_result.game.me.point).to(eq(7))
      expect(room_result.game.him.point).to(eq(0))
    end
  end
end
