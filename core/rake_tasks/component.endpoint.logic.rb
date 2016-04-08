class ComponentGenerator
  class Endpoint < Base
    class Logic < Base
      def directory
        "#{@generator.directory}/endpoint/logic"
      end

      def domain
        self.class::Domain.new(self)
      end

      def spec
        self.class::Spec.new(self)
      end

      def template
        <<-EOF
class Component::#{class_name}::Endpoint::Logic
  def initialize(request)
    @request = request
  end
end
        EOF
      end
    end
  end
end
