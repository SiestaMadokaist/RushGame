module Ramadoka::Entity
end

class Ramadoka::Entity::Base < Grape::Entity
end

class Ramadoka::Entity::Errors < Grape::Entity
  expose(:code, documentation: {type: "Integer"}, as: :error_code)
  expose(:message, documentation: {type: "String"})
end
