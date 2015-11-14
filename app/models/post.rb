require 'redcarpet'

class Post < ActiveRecord::Base
  def self.latest_post
    order(:authored_at).last
  end

  def rendered_body
    renderer = HtmlWithPygments.new(prettify: true)
    markdown = Redcarpet::Markdown.new(renderer, fenced_code_blocks: true)
    markdown.render(self.body.html_safe)
  end
end
