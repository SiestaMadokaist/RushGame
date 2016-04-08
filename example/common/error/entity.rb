module ERR
  class Presenter < Grape::Entity
    expose(:code, as: :error_code, documentation: {type: "Integer"}) do |err, opt|
      if(opt[:code])
        opt[:code]
      elsif err.respond_to?(:code)
        err.code
      else
        503
      end
    end
    expose(:message, documentation: {type: "String"})
  end
end
