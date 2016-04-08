class ComponentGenerator
  class Entity < Base

    def directory
      "#{@generator.directory}/entity"
    end

    def template
      <<-EOF
module Component::#{class_name}::Entity
  class Lite < Grape::Entity
    class << self
      # @!visibility private
      def self._id
      end

      def nullified
      end
    end
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
      EOF
    end
  end
end
