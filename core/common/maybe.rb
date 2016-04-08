class Just

  def initialize(value)
    @value = value
  end

  def map(methodsymbol=nil, *args, &block)
    if((not methodsymbol.nil?) and block_given?)
      raise BlockMethod, "argument should be either methodsymbol, or block process"
    end

    if(block_given?)
      result = block.call(self.value) || Nothing
    else
      begin
        result = self.value.send(methodsymbol, *args)
      rescue NoMethodError
        result = Nothing
      end
    end

    Maybe.from_value(result)
  end

  def ==(other)
    (@value == other.value) && (other.class == Just)
  end

  def value(anything = nil, &block)
    @value
  end
end

class Nothing
  def self.map(methodsymbol=nil, *args, &block)
    self
  end

  def self.is?(something)
    return self == something
  end

  def self.value(default = nil, &block)
    if(block.nil?)
      default
    else
      block.call
    end
  end
end

class Maybe
  def self.from_value(value, &block)
    if(value.nil? || Nothing.is?(value))
      return Nothing
    else
      return Just.new(value)
    end
  end
end
