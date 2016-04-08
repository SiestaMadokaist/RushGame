class ComponentGenerator
  class Endpoint < Base
    class Params < Base
      def directory
        "#{@generator.directory}/endpoint/params"
      end

      def domain
        self.class::Domain.new(self)
      end

      def spec
        self.class::Spec.new(self)
      end

      def template
        <<-EOF
class Component::#{class_name}::Endpoint::Params
  # params for "/"
  def self.root(params)
    # params.requires(:something, desc: "something", type: Integer)
    # params.optional(:something, desc: "something-else", type: String)
  end
end
        EOF
      end
    end
  end
end
