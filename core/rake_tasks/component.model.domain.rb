class ComponentGenerator
  class Model < Base
    class Domain < Base
      def directory
        "#{@generator.directory}/domain"
      end

      def template
        <<-EOF
class Component::#{class_name}::Domain

end
        EOF
      end
    end
  end
end
