class ComponentGenerator
  class Base
    def initialize(generator)
      @generator = generator
    end

    def path
      "#{Dir.pwd}/#{directory}/init.rb"
    end

    def directory
      raise NotImplementedError
    end

    def create!
      FileUtils.mkdir_p(directory)
      File.open(path, 'w'){|f| f.write(template) }
    end

    def name
      @generator.name
    end

    def class_name
      name.camelize
    end

    def template
      raise NotImplementedError
    end
  end
end
