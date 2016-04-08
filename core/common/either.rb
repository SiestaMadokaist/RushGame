class Success

  def initialize(value)
    @value = value
  end

  def map(on_failure=Either.do_nothing, &on_success)
    begin
      result = on_success.call(@value)
    rescue => err
      Failure.new(err)
    else
      Success.new(result)
    end
  end

  def handle(&callback)
    self
  end

  def ==(other)
    (@value == other.value) && (other.class == Success)
  end

  def data
    value
  end

  def value
    @value
  end

end

class Failure

  extend Memoist

  def initialize(error)
    @error = error
  end

  def map(on_failure=nil, &success_block)
    return self if on_failure.nil?
    begin
      result = on_failure.call(@error)
    rescue => e
      Failure.new(e)
    else
      Success.new(result)
    end
  end

  def value
    as_json
  end

  def data
    wrapper = OpenStruct.new
    wrapper.error = @error
    wrapper.message = @error.message
    wrapper.error_code = error_code
    wrapper.http_code = http_code
    wrapper
  end
  memoize(:data)

  def error_code
    # TODO
  end

  def http_code
    # TODO
  end

  def as_json
    {
      error: @error.class.name,
      failure: true,
      error_code: error_code,
      http_code: http_code
    }
  end

end

class Either

  def self.do_nothing
    ->(identity) { identity }
  end

  def self.from_value(&callback)
    begin
      result = callback.call
    rescue => e
      Failure.new(e)
    else
      Success.new(result)
    end
  end
end


