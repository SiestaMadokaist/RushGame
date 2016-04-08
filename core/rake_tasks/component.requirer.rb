class ComponentGenerator
  class Requirer < Base
    def directory
      "#{@generator.directory}"
    end

    def template
      <<-EOF
module Component; end
require File.expand_path("../model/init.rb", __FILE__)
require File.expand_path("../model/domain/init.rb", __FILE__)
require File.expand_path("../entity/init.rb", __FILE__)
      EOF
    end
  end
end
