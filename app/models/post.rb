class Post < ActiveRecord::Base
  def self.latest_post
    order(:created_at).last
  end
end
