module Component::Room::Entity
  class Lite < Grape::Entity
    class << self
      # @!visibility private
      def self._id
      end

      def nullified
      end

    end
    expose(:algorithm_name, documentation: {type: String})
    expose(:id, documentation: {type: Integer})
    expose(:ai, documentation: {type: RushGame::Player}) do |room, opt|
      room.ai if(opt[:see_through])
    end
    expose(:challenger, documentation: {type: RushGame::Player})
    expose(:com, documentation: {type: RushGame::Player})
    expose(:storage, documentation: {type: Integer})
    expose(:com_card, documentation: {type: Integer})
  end

  class Regular < Grape::Entity
    class << self
      # @!visibility private
      def self._id
      end

      def nullified
      end
    end
  end
end
