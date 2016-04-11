module Component::Room::Endpoint
end
class Component::Room::Endpoint::V1 < Ramadoka::Endpoint::Base

  extend RushGame::Mixins::ResponsePresenter
  resource("/rooms")
  success do |presenter, result, request|
    Common::Primitive::Entity.show(data: result, see_through: result.see_through, presenter: presenter)
  end
  failure(&response_error)

  def route_create
    room = Component::Room.new(params[:algorithm], nil, params[:see_through])
    @ai = RushGame::Player.new(room.ai.name, [], 0)
    room
  end

  route!(:route_create) do
    path("/create")
    method(:post)
    description("create a new room")
    optional(:algorithm, type: Symbol, values: [:deterministic, :deterministic2, :roulette, :purerandom], default: :deterministic)
    optional(:see_through, type: Symbol, values: [:true, :false], default: :false)
    presenter(Component::Room::Entity::Lite)
    success do |presenter, result, req|
      Common::Primitive::Entity.show(
        data: result,
        ai: req.ai,
        presenter: presenter
      )
    end
  end

  def route_retrieve
    Component::Room.retrieve(params[:room_id])
  end
  route!(:route_retrieve) do
    path("/retrieve")
    method(:get)
    description("recheck the current condition")
    required(:room_id, type: String)
    error(Component::Room::RoomNotInitialized)
    presenter(Component::Room::Entity::Lite)
  end

  attr_reader(:ai)
  def route_play
    prev = Component::Room.retrieve(params[:room_id])
    current = prev.play!(params[:card_id])
    ai_ammo = prev.ai.ammo.select{|x| not current.ai.ammo.include?(x)}
    @ai = RushGame::Player.new(prev.ai.name, ai_ammo, current.ai.point)
    current
  end

  route!(:route_play) do
    path("/play")
    method(:post)
    description("play the selected card")
    required(:room_id, type: String)
    required(:card_id, type: Integer)
    error(RushGame::Player::ErrInvalidCard, 403)
    error(Component::Room::RoomNotInitialized)
    success do |presenter, result, req|
      Common::Primitive::Entity.show(
        data: result,
        ai: req.ai,
        presenter: presenter
      )
    end
    presenter(Component::Room::Entity::Lite)
  end

end
