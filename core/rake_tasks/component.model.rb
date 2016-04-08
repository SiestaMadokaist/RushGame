class ComponentGenerator
  class Model < Base

    def directory
      "#{@generator.directory}/model"
    end

    def domain
      self.class::Domain.new(self)
    end

    def spec
      self.class::Spec.new(self)
    end

    def template
      <<-EOF
class Component::#{class_name} < ActiveRecord::Base
  extend Memoist

  def domain
    self.class::Domain.new(self)
  end
  memoize(:domain)

end
      EOF
    end
  end
end
