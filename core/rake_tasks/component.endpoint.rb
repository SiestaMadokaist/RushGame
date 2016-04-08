class ComponentGenerator
  class Endpoint < Base

    def self.run!(args)
      generator = ComponentGenerator.new(args[:component_name])
      has_no_args = args[:version].nil? && args[:directive].nil?
      if(has_no_args)
        versions = (1..4).to_a
        directives = ["web", "mobile"]
        directives.each do |d|
          versions.each do |v|
            g = ComponentGenerator::Endpoint.new(generator, d, v)
            puts(g)
            g.create!
          end
        end
      end
      logic = ComponentGenerator::Endpoint::Logic.new(generator)
      params = ComponentGenerator::Endpoint::Params.new(generator)

      logic.create!
      params.create!
    end

    def to_s
      "<Endpoint @directive=#{@directive} @version=#{@version}>"
    end

    # @params generator
    # @params directive [String]
    # e.g: web/mobile
    # @params version [Integer]
    # e.g: 1/2/3/4
    def initialize(generator, directive, version)
      @generator = generator
      @directive = directive
      @version = version
    end

    def namespace
      "v#{@version}/#{@directive}"
    end

    def directory
      "#{@generator.directory}/endpoint/#{namespace}"
    end

    # @params directive [String]
    # values: web/mobile/something else
    # @params version [Integer]
    # values: 1, 2, 3, 4
    def template(directive="web", version=1)
      <<-EOF
class Component::#{class_name}::Endpoint::V#{@version}::#{@directive.capitalize} < Grape::API
  Params = Component::#{class_name}::Endpoint::Params
  Logic = Component::#{class_name}::Endpoint::Logic

  format :json

  resource "#{name.pluralize}" do
    # desc("description for this endpoint")
    # params{ Params.route_name(self) }
    # get("/route"){ Logic.route_name(self) }
  end
end
      EOF
    end

  end
end

