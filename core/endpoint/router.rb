class Ramadoka::Endpoint::Router
  attr_accessor(:resource, :callback, :errors, :optionals, :requireds, :path, :description, :presenter, :method, :headers)
  # @param klass [Class]
  # @param callback [Symbol]
  # @param resource [String]
  def initialize(klass, callback, resource)
    @klass = klass
    @callback = callback
    @resource = resource
    @errors = []
    @optionals = []
    @requireds = []
    @headers = {}
    @success_block = nil
    @failure_block = nil
    @presenter = nil
  end

  def endpoint
    @klass
  end

  def meta_copy_to_different_klass(other_klass)
    copy = self.class.new(other_klass, @callback, @resource)
    copy.errors = @errors
    copy.optionals = @optionals
    copy.requireds = @requireds
    copy.path = @path
    copy.description = @description
    copy.presenter = @presenter
    copy.method = @method
    copy.resource = @resource
    copy.success(&@success_block)
    copy.failure(&@failure_block)
    copy.headers = @headers
    copy
  end

  # @param value [String]
  def path(value)
    @path = value
  end

  # @param value [String]
  def description(value="")
    @description = "(#{@klass}.#{@callback}) - #{value}"
  end

  # @param value [Class] subclass of Grape::Entity
  def presenter(value)
    @presenter = value
    # @presenter_block = block
  end

  # @param name [Symbol]
  # @param details [Hash]
  # @param details :description :optional [String]
  # @param details :required :optional [Boolean]
  def header(name, details = {})
    @headers[name] = details
  end

  def success(&block)
    @success_block = block
  end

  def failure(&block)
    @failure_block = block
  end

  # @param error_code [Integer]
  # @param err [Class]
  def error(err, err_code=nil)
    error_code = Fallback.new(err_code)
      .fallback_to{ err.code if err.respond_to?(:code) }
      .fallback_to(503)
      .value
    @errors << [error_code, err.name, Ramadoka::Entity::Errors]
  end

  # @param value [Symbol]
  # @param value Value: [:post, :get, :delete, :head, :, ...]
  def method(value)
    @method = value
  end

  # @param name [Symbol]
  # @param options :type :optional
  # @param options :default :optional
  def optional(name, options={})
    param = OpenStruct.new
    param.name = name
    param.options = options
    param.required = false
    param.category = :optional
    @optionals << param
  end

  # @param name [Symbol]
  # @param options :type :optional
  # @param options :default :optional
  def required(name, options={})
    param = OpenStruct.new
    param.name = name
    param.options = options
    param.required = true
    param.category = :requires
    @requireds << param
  end

  def params
    @requireds + @optionals
  end

  # @param klass [Class]
  # subclass of Grape::API, a mounted_class
  def add_logic_to(klass)
    _description = @description
    _presenter = @presenter || @klass.presenter_entity
    _errors = @klass.errors + @errors
    _params = params
    _headers = @headers
    _method = @method
    _path = @path
    _klass = @klass # the logic class
    _callback = @callback
    _resource = @resource
    _on_success = @success_block || @klass.success_handler
    _on_failure = @failure_block || @klass.failure_handler
    klass.instance_exec do
      resource _resource do
        desc(
          _description,
          entity: _presenter,
          http_codes: _errors,
          headers: _headers
        )
        params do
          _params.each{|p| send(p.category, p.name, p.options) }
        end
        send(_method, _path) do
          req = _klass.new(self)
          begin
            result = req.send(_callback)
          rescue => e
            STDERR.write("#{e.class}\n#{e}\n\n")
            STDERR.write(e.backtrace.join("\n"))
            _on_failure.call(_presenter, e, _errors, req)
          else
            _on_success.call(_presenter, result, req)
          end
        end
      end
    end
  end
end
