class PostsController < ApplicationController
  def index
    @posts = Post.order(:authored_at => :desc).limit(10)
  end

  def show
    @post = Post.find_by_permalink(params[:id])
    raise ActionController::RoutingError.new('Not Found') unless @post
  end
end
