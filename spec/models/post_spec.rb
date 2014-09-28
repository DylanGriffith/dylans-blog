require 'rails_helper'

describe Post do
  it 'works' do
    Post
  end

  describe '::latest_post' do
    before(:each) do
      Post.create(:title => "first post title", :body => "first post body", :authored_at => Time.new(2013, 1, 1))
      Post.create(:title => "last post title", :body => "last post body", :authored_at => Time.new(2014, 1, 1))
      Post.create(:title => "oldest post title", :body => "oldest post body", :authored_at => Time.new(2012, 1, 1))
    end

    it 'returns the most recent post' do
      post = Post.latest_post
      expect(post.title).to eq("last post title")
      expect(post.body).to eq("last post body")
    end
  end
end
