require File.expand_path("../lib/crows", File.dirname(__FILE__))

scope do
  class User; end

  class Post
    def self.all
      ['post 1', 'post 2']
    end
  end

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

    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        if true
          scope.all
        end
      end
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

  test "throw an exception if authorization fails" do
    assert_raise(Crows::NotAuthorizedError) do
      @controller.authorize(@post, :destroy?)
    end
  end

  test "throws an exception when a crow class cannot be found" do
    assert_raise(Crows::NotDefinedError) do
      @controller.authorize(@user, :update?)
    end
  end

  test "returns an instantiated crow" do
    crow = @controller.crow(@post)
    assert_equal crow.post, @post
  end

  test "throws an exception when a crow class cannot be found in #crow" do
    assert_raise(Crows::NotDefinedError) do
      @controller.crow(@user)
    end
  end

  test "allow crow to be injected" do
    crow = @controller.crow(@post)
    @controller.crows[@post] = crow
    assert_equal @controller.crows[@post], crow
  end

  test "save the crow" do
    assert_equal @controller.crows[Post.new], nil
    crow = @controller.crow(@post)
    assert_equal @controller.crows[@post], crow
  end

  test "returns an instantiated crow scope" do
    scope = @controller.crow_scope(Post)
    assert_equal scope, ['post 1', 'post 2']
  end

  test "throws an exception when a crow scope class cannot be found" do
    assert_raise(Crows::NotDefinedError) do
      @controller.crow_scope(User)
    end
  end

  test "crow_user return the same current_user of controller" do
    assert_equal @controller.crow_user, @controller.current_user
  end
end