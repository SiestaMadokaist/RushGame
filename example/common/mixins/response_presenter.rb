module Sembako
end
module Sembako::Mixins;
end
module Sembako::Mixins::ResponsePresenter
  def response_with_paging
    proc do |presenter, result, request|
      Common::Primitive::Entity.show(data: result, presenter: presenter, pagination: {page: request.page, per_page: request.per_page})
    end
  end

  def response_no_paging
    proc do |presenter, result, _|
      Common::Primitive::Entity.show(data:result, presenter:presenter)
    end
  end

  def response_error
    proc do |_, err, known_errors, _|
      error_pack = known_errors
        .select{|c, m, p| m == err.class.name}
        .first
      if (error_pack.nil?)
        presenter = ERR::Presenter
      else
        code, _, presenter = error_pack
      end
      Common::Primitive::Entity.show(data: [err], code: code, error: true, presenter: presenter)
    end
  end
end
