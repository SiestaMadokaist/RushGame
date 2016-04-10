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
    Component::Room.new(params[:algorithm], nil, params[:see_through])
  end

  route!(:route_create) do
    path("/create")
    method(:post)
    description("create a new room")
    optional(:algorithm, type: Symbol, values: [:deterministic, :deterministic2, :roulette, :purerandom], default: :deterministic)
    optional(:see_through, type: Symbol, values: [:true, :false], default: :true)
    presenter(Component::Room::Entity::Lite)
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

  def route_play
    Component::Room.retrieve(params[:room_id])
      .play!(params[:card_id])
  end

  route!(:route_play) do
    path("/play")
    method(:post)
    description("play the selected card")
    required(:room_id, type: String)
    required(:card_id, type: Integer)
    error(RushGame::Player::ErrInvalidCard, 403)
    error(Component::Room::RoomNotInitialized)
    presenter(Component::Room::Entity::Lite)
  end

end
