require 'rails_helper'

describe Post do
  it 'works' do
    Post
  end

  describe '::latest_post' do
    before(:each) do
      Post.create(:title => "first post title", :body => "first post body")
      Post.create(:title => "last post title", :body => "last post body")
    end

    it 'returns the most recent post' do
      post = Post.latest_post
      expect(post.title).to eq("last post title")
      expect(post.body).to eq("last post body")
    end
  end
end
