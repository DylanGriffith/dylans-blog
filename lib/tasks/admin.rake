namespace :admin do
  desc "Create or update a post from a file"
  task :update_post, [:file_name] => [:environment] do |t, args|
    file_path = Pathname.new(args[:file_name])
    PostUpdater.update_post(file_path)
  end

  desc "Iterates all .md files in blog_posts directory and creates or updates posts by title"
  task :update_posts => :environment do
    Pathname.new("./blog_posts").find do |file|
      if file.extname == ".md"
        PostUpdater.update_post(file)
      end
    end
  end
end
