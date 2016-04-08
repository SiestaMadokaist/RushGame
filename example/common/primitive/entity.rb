module Common; end
module Common::Primitive; end
class Common::Primitive::Entity < Grape::Entity
  def count(item, options)
    return options[:data_count] unless options[:data_count].nil?
    return options[:data].count if options[:data].respond_to?(:count)
    return options[:data].length if options[:data].respond_to?(:length)
    return 1 unless options[:data].nil? || options[:data].blank?
    0
  end

  def message(item, options)
    return options[:message] unless options[:message].nil?
    return item.message if item.respond_to?(:message)
    ""
  end

  def error(item, options)
    return options[:error] unless options[:error].nil?
    return item.error if item.respond_to?(:error)
    false
  end

  class << self
    def show(options = {})
      represent({}, options)
    end
  end

  expose(:data_count) do |item, options|
    count(item, options)
  end
  expose(:message) do |item, _|
    message(item, options)
  end
  expose(:error) do |item, _|
    error(item, options)
  end
  expose(:data) do |item, options|
    data = options[:data]
    presenter = options[:presenter]
    if(presenter.nil?)
      data
    else
      if(options[:pagination].nil?)
        presenter.represent(data, options)
      else
        pagination = options[:pagination]
        presenter.represent(data.paginate(per_page: pagination[:per_page], page: pagination[:page]), options)
      end
    end
  end
end
