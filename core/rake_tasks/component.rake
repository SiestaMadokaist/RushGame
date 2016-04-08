require File.expand_path("../../common/either", __FILE__)
require File.expand_path("../component.base.rb", __FILE__)
Dir["#{File.dirname(__FILE__)}/component.*.rb"].each{|f| require f}

class ComponentGenerator
  class InvalidArgument < StandardError; end

  extend Memoist

  def self.validate!(argument)
    raise InvalidArgument if argument.count != 1
    raise InvalidArgument if argument[:component_name].nil?
  end

  def self.run!(args)
    Either
      .from_value{ validate!(args) }
      .map(->(err){ puts message }){ new(args[:component_name]).create! }
  end

  def self.message
    "Run this task via: rake g:component[<component-name>]"
  end

  def initialize(name)
    @name = name
  end

  def name
    @name
  end

  def create!
    requirer.create!
    model.create!
    model.domain.create!
    model.spec.create!
    entity.create!
    factory.create!
  end

  def directory
    "component/#{name}"
  end

  def factory
    self.class::Factory.new(self)
  end

  def requirer
    self.class::Requirer.new(self)
  end
  memoize(:requirer)

  def model
    self.class::Model.new(self)
  end
  memoize(:model)

  def endpoints
    ["web", "mobile"].map do |directive|
      (1..4).each do |version|
        self.class::Endpoint.new(self, directive, version)
      end
    end
  end
  memoize(:endpoints)

  def entity
    self.class::Entity.new(self)
  end
  memoize(:entity)

end

namespace :g do
  task :component, :component_name do |t, args|
    ComponentGenerator.run!(args)
  end

  task :factory, :component_name do |t, args|
    ComponentGenerator.new(args[:component_name]).factory.create!
  end

  task :endpoint, :component_name do |t, args|
    ComponentGenerator::Endpoint.run!(args)
  end
end
