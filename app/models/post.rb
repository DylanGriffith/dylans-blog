require 'redcarpet'

class Post < ActiveRecord::Base
  def self.latest_post
    order(:created_at).last
  end

  def rendered_body
    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer)
    markdown.render(self.body.html_safe).html_safe
  end
end
