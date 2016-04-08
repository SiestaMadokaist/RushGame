class ComponentGenerator
  class Factory < Base
    LineSeparator = "# --- DO NOT REMOVE/CHANGE THIS LINE ---"
    def initialize(generator)
      super(generator)
      read_current_template!
    end

    def directory
      "component/#{name}/factory"
    end

    def null_message(col)
      return "" if col.null
      "NOT NULL"
    end

    def default(col)
      return "" if col.default.nil?
      return " default: #{col.default}"
    end

    def read_current_template!
      require "application"
      begin
        @current_template = File.open(path).read.split("\n")
      rescue => e
        @current_template = []
      end
    end

    def current_factory_source_code
      current_factories.empty? ? default_factory : current_factories.join("\n")
    end

    def default_factory
      <<-EOF

FactoryGirl.define do
  factory(:#{name}) do
  end
end
      EOF
    end

    def current_factories
      @current_template
        .drop_while{|line| line != LineSeparator}
        .drop(1)
    end

    def template
      table = eval("Component::#{name.camelize}")
      output = table
        .columns
        .map{|col| "# - :#{col.name} #{null_message(col)} [#{col.type.to_s.camelize}]#{default(col)}"}
      header =[
        "# #{name.camelize} details:",
        "# table_name: `#{table.table_name}`",
        "# attributes:"
      ]
      <<-EOF
#{(header + output).join("\n")}

#{LineSeparator}
#{current_factory_source_code}
      EOF
    end

  end
end
