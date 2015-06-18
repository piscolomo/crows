# Copyright (c) 2015 Julio Lopez

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
module Crows
  VERSION = "0.1.0"
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
    instance = find_crowclass(record).new(crow_user, record)
    crows[record] = instance unless record.is_a? Class
    instance
  end

  def crow_scope(klass)
    crows_scope[klass] = crow(klass)
    crows_scope[klass].resolve
  end

  def authorize(record, query)
    crow = crow(record)
    unless crow.public_send(query)
      raise NotAuthorizedError.new(query: query, record: record)
    end
    true
  end

  def crow_user
    current_user
  end

  def crows
    @crows ||= {}
  end

  def crows_scope
    @crows_scope ||= {}
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