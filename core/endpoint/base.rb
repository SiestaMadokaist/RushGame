class Ramadoka::Endpoint::Base

  @routes = {}
  @mounted_class = Class.new(Grape::API)
  @resource = "base"
  @errors = []

  extend Memoist

  class << self
    def get_route(path)
      if(self == Ramadoka::Endpoint::Base)
        @routes[path] || @routes["404"]
      else
        if(not @routes[path].nil?)
          @routes[path]
        else
          superclass.get_route(path)
        end
      end
    end

    def initialize_route!
      @routes = {}
    end

    def initialize_mounted_class!
      @mounted_class = Class.new(Grape::API)
    end

    def initialize_errors
      @errors = []
    end

    def routes
      @routes
    end

    # @param methodname: [Symbol]
    # @param lresource: [String]
    def route!(methodname, custom_resource = nil, &logic)
      raise ErrInvalidMethodName, "methodname must start with 'route'" unless methodname.to_s.match(/^route/)
      func_resource = Fallback.new(custom_resource)
        .fallback_to{ resource_value }
        .value
      router = Ramadoka::Endpoint::Router.new(self, methodname, func_resource)
      router.instance_exec(&logic)
      router.add_logic_to(@mounted_class)
      @routes[methodname] = router
    end

    def copy_parent_logic!
      @routes.each do |methodname, prouter|
        my_router = prouter.meta_copy_to_different_klass(self)
        my_router.add_logic_to(@mounted_class)
      end
    end

    def inherit!
      superclass.routes.each do |methodname, prouter|
        if(routes[methodname].nil?)
          routes[methodname] = prouter
          new_router = prouter.meta_copy_to_different_klass(self)
          new_router.add_logic_to(@mounted_class)
        end
      end
    end

    def inherited(subklass)
      subklass.initialize_route!
      subklass.initialize_mounted_class!
      subklass.initialize_errors
    end

    def resource(value)
      @resource = value
    end

    def resource_value
      Fallback.new(@resource)
        .fallback_to{ superclass.resource }
        .value
    end

    def success(&on_success)
      @on_success = on_success
    end

    def failure(&on_failure)
      @on_failure = on_failure
    end

    def mounted_class
      @mounted_class
    end

    def success_handler
      Fallback.new(@on_success)
        .fallback_to{ superclass.success_handler }
        .value
    end

    def failure_handler
      Fallback.new(@on_failure)
        .fallback_to{ superclass.success_handler }
        .value
    end

    def presenter_entity
      Fallback.new(@presenter_entity)
        .fallback_to{ superclass.presenter_entity }
        .value
    end

    # @param entity [Class]
    # subclass of Grape::Entity
    def presenter(presenter_entity)
      @presenter_entity = presenter_entity
    end

    # @param entity [Class]
    # subclass of Grape::Entity
    def error_presenter(error_entity)
      @error_entity = error_entity
    end

    attr_reader(:errors)
    def base_error(err, err_code=nil)
      error_code = Fallback.new(err_code)
        .fallback_to{ err.code if err.respond_to?(:code)}
        .fallback_to(503)
        .value
      @errors << [error_code, err.name, @error_entity]
    end

  end

  success{|_, result, _| result}
  failure{|_, err, _| err}

  attr_reader(:request)
  def initialize(request)
    @request = request
  end

  def header
    @request.header
  end

  def headers
    @request.headers
  end

  def params
    @request.params
  end

  def page
    params[:page]
  end

  def per_page
    params[:per_page]
  end

end
