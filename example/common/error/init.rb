module ERR
  class CustomError < StandardError
    def self.code
      raise NotImplementedError
    end

    def self.message
      # TODO
      self.name
    end
  end

  class ServerError503 < CustomError
    def self.code
      503
    end
  end

  class Forbidden403 < CustomError
    def self.code
      403
    end
  end

  class NoAuthorization401 < CustomError
    def self.code
      401
    end
  end

  class NotFound404 < CustomError
    def self.code
      404
    end
  end
end
