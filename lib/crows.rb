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

  def crows
    @crows ||= {}
  end

  def authorize(record, query)
    name_class = record.class.to_s + SUFFIX
    instance = Object.const_get(name_class).new(current_user, record)
    unless instance.public_send(query)
      raise NotAuthorizedError.new(query: query, record: record)
    end
  end
end

# #Usage:

# class User
#   def initialize(name)
#     @name = name
#   end

#   def admin?
#     true
#   end
# end

# class Post

# end

# class PostCrow
#   attr_reader :user, :post

#   def initialize(user, post)
#     @user = user
#     @post = post
#   end

#   def update?
#     user.admin?
#   end
# end

# def current_user
#   User.new "Julio"
# end

# class ApplicationController
  

#   extend Crows

#   @post = Post.new
#   puts authorize @post, :update?
#   #return true
# end