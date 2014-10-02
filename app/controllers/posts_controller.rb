class PostsController < ApplicationController
  def index
    @posts = Post.order(:authored_at => :desc).limit(10)
  end
end
