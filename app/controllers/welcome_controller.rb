class WelcomeController < ApplicationController
  def index
    @post = Post.latest_post
  end
end
