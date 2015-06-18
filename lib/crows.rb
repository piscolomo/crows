module Crows
  SUFFIX = "Crow"

  class NotDefinedError < StandardError; end
  class NotAuthorizedError < StandardError
    def initialize(options = {})
      query  = options[:query]
      record = options[:record]
      message = "not allowed to #{query} this #{record.inspect}"
      super(message)
    end
  end

  def find_crow_of(record)
    klass = Object.const_get(record.class.to_s + SUFFIX)
  rescue NameError
    raise NotDefinedError, "unable to find crow #{klass} for #{record.inspect}"
  end

  def authorize(record, query)
    instance = find_crow_of(record).new(current_user, record)
    unless instance.public_send(query)
      raise NotAuthorizedError.new(query: query, record: record)
    end
    true
  end
end