require File.expand_path("../lib/crows", File.dirname(__FILE__))

scope do
  class User; end

  class Post; end

  class PostCrow
    attr_reader :user, :post

    def initialize(user, post)
      @user = user
      @post = post
    end

    def update?
      true
    end

    def destroy?
      false
    end
  end

  class Controller
    include Crows
    attr_reader :current_user
    def initialize(user)
      @current_user = user
    end
  end

  @user = User.new
  @controller = Controller.new @user
  @post = Post.new

  test "return true if authorization passes" do
    action = @controller.authorize(@post, :update?)
    assert_equal action, true
  end

  test "throw an error if authorization fails" do
    assert_raise(Crows::NotAuthorizedError) do
      @controller.authorize(@post, :destroy?)
    end
  end
end