class PostUpdater
  def self.update_post(file_path)
    raise "cannot find file #{file_path}" unless file_path.file?
    index, title, body, time, permalink = 0, "", "", nil, ""
    file_path.each_line do |line|
      if index == 0
        title = line.chomp
        permalink = ActiveSupport::Inflector.parameterize(title)
      elsif index == 1
        begin
          time = Time.parse(line.chomp)
        rescue StandardError
          puts "no time info for #{title}, using Time.now if creating"
        end
      else
        body += line
      end
      index += 1
    end
    post = Post.find_or_create_by(:permalink => permalink)
    time ||= (post.authored_at || Time.now)
    post.update_attributes!(:body => body, :authored_at => time, :title => title)
    puts "successfully created or updated post with id=#{post.id}"
  end
end
