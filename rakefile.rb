require 'rake'
require 'controllers'

namespace :db do 
  task :migrate do
    DataMapper.auto_migrate!
  end
  
  task :populate do
    Rake::Task["data:migrate"].invoke
    
    post = Post.new
    post.title = "This is a title"
    post.body = "BODY BODY BODY"
    post.mtime = Time.now
    post.file = "asdf.markdown"
    post.save
    
    flex = Tag.new
    flex.name = "Flex"
    
    ruby = Tag.new
    ruby.name = "Ruby"
    
    post.tags << flex
    
    post.save
    flex.save
    ruby.save
  end
end


namespace :scan do
  
  desc "Scan posts directory and import posts using maruku"
  task :posts do
    posts = Posts.new
    posts.scan_posts
  end
  
  task :pages do
    posts = Posts.new
    posts.scan_pages
  end
  
  task :all do
    scan = Scan.new
    scan.posts
    scan.pages
  end
end