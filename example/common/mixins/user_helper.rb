module Sembako; end
module Sembako::Mixins; end
module Sembako::Mixins::UserHelper
  def user
    Component::User.find_by_token(headers["Authorization"])
  end
end
