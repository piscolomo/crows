# Crows

Inspired by [Pundit](https://github.com/elabs/pundit), Crows is a micro framework-agnostic library for authorization in Ruby classes.

A set of crows for authorize your users, because the night is dark and full of terrors...

![Crows](https://s-media-cache-ak0.pinimg.com/736x/d5/b6/1e/d5b61ee4b6f7f390e467c64cfefe6993.jpg)

Crows provide you with a few helpers to check if `current_user` can make operations into some records. This gives you the freedom to build your own plain Ruby classes to make authorization works easily, without the painful of bigs DSLs or something like that.

## Installation

Installing Crows is as simple as running:

```
$ gem install crows
```

Include Crows in your Gemfile with gem 'crows' or require it with require 'crows'.

Usage
-----

Include Crows in your main class, can be your controller, your API class, etc.

``` ruby
class ApplicationController < ActionController::Base
  include Crows
end
```

Crows exist around the notion of Crow classes.

``` ruby
class PostCrow
  attr_reader :user, :post

  def initialize(user, post)
    @user = user
    @post = post
  end

  def destroy?
    user.admin? and post.draft?
  end
end
```

In the above example:

-  We define a Crow class, its name is composed by a name of a class whose authorization you want to check, plus the suffix "Crow".
- In its `initialize` the class receive as first argument the user(captured by your method `current_user`) and as second argument your instance of the class for which was created the current crow.
- Finally the Crow class implements methods to check if user can be authorized to do a particular action.

Lastly, you have the `authorize` method for use your Crow class.

``` ruby
authorize @post, :destroy?
```

The above line will check your PostCrow class to authorize if current user can destroy the @post

An exception is raised if is not true the result of `destroy?`

``` ruby
Crows::NotAuthorizedError: not allowed to destroy? this #<Post:0x007fd1831adc48>
```

Also, you have a method `crow` to receive the instance of your Crow class for handle the check manually, useful in the views:

``` erb
<% if crow(@post).destroy? %>
  <%= link_to "Delete post", post_path(@post), method: :delete %>
<% end %>
```

## Scopes

You can also declare a Scope in your Crow class, use it when you need to check if the user can access to a list of records, looks like this:

``` ruby
class PostCrow
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        scope.select{|post| post.published }
      end
    end
  end
end
```

To make the Scope class works: 
- You need to create it nested in your Crow class.
- In its `initialize` the class Scope receive as first argument the `current_user`(similar as works the Crow classes) and as second argument the scope(a class name) that you'll pass later to the `authorize` method
- And you need to declare the `resolve` method, which should check the authorization and return something that can be iterated(that is the reason why it is called scope, isn't it?)

Now, you can use your scopes like this:

``` erb
<% crow_scope(Post).each do |post| %>
  <p><%= link_to post.title, post_path(post) %></p>
<% end %>
```

This example will return all the posts if the user is admin, if not it will return just the published posts, as we indicated in the `resolve` method.

## Customize your current user

Sometimes, you'll need to authorize users outside your main class(your controller, API class, etc), in that case you simply need to Crows call other method than `current_user` and we give you for that, the option of define the `crow_user`

```ruby
def crow_user
  #grab here the user that you want to check his authorization
  User.find(params[:user_id])
end
```

## Get and Set Crows

For other purposes you can get the hash of all crows and scopes defined with `crows` and `crows_scope` methods (use them in the class where you include Crows)

Following the previous examples:

```ruby
class ApplicationController
  puts crows
  #=>{<Post:instance> => <PostCrow:instance>}

  puts crows_scope
  #=>{Post => #result of PostCrow::Scope.resolve}
end
```

And you can set manually the crows with a hash syntax:

```ruby
class ApplicationController
  crows[@post] = crow(@post)
  crows_scope[Post] = crow_scope(Post)
end
```