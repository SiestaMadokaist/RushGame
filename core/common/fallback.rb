class Fallback
  class EmptyFallback; end
  def initialize(value)
    @_value = value
  end

  # TODO:
  # test whether using &block is behaving as it should be
  def fallback_to(v=EmptyFallback, &block)
    return self unless value.blank?
    if(block_given?)
      Fallback.new(block.call)
    elsif(v != EmptyFallback)
      Fallback.new(v)
    else
      raise "Expected a value of callback"
    end
  end

  # for any other method than .fallback_to or .value
  # it's assummed that it tries to call a method of the object @value
  # well, except for things like, .nil?
  def method_missing?(m, *args, &block)
    message ="Neither Fallback nor #{@_value.class} respond to #{m}"
    raise message unless @_value.respond_to(m)
    @_value.send(m, *args, &block)
  end

  def value
    @_value
  end


end
