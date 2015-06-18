module Crows
  SUFFIX = "Crow"
  class NotAuthorizedError < StandardError
    def initialize(options = {})
      query  = options[:query]
      record = options[:record]
      message = "not allowed to #{query} this #{record}"
      super(message)
    end
  end

  def authorize(record, query)
    name_class = record.class.to_s + SUFFIX
    instance = Object.const_get(name_class).new(current_user, record)
    unless instance.public_send(query)
      raise NotAuthorizedError.new(query: query, record: record)
    end
    true
  end
end