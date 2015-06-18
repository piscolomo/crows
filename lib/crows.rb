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

  def crow(record)
    find_crowclass(record).new(current_user, record)
  end

  def crow_scope(klass)
    crow(klass).resolve
  end

  def authorize(record, query)
    crow = crow(record)
    unless crow.public_send(query)
      raise NotAuthorizedError.new(query: query, record: record)
    end
    true
  end

  private

  def find_crowclass(record)
    klass = if record.is_a? Class
      Object.const_get(record.to_s + SUFFIX)::Scope
    else
      Object.const_get(record.class.to_s + SUFFIX)
    end
  rescue NameError
    raise NotDefinedError, "unable to find crow #{klass} for #{record.inspect}"
  end
end