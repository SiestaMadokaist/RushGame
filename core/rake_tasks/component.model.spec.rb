class ComponentGenerator
  class Model < ComponentGenerator::Base
    class Spec < ComponentGenerator::Base

      def path
        "#{directory}/spec.rb"
      end

      def directory
        "#{@generator.directory}/spec"
      end

      def template
        <<-EOF
describe Component::#{class_name}::Domain do
  it "run the test" do
    expect(1).to(eq(1))
  end
end
        EOF
      end
    end
  end
end
