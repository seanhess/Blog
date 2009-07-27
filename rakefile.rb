require 'rake'
require 'data/init'
require 'controllers'

namespace :db do 
  task :migrate do
    # DataMapper.auto_migrate!
    # Post.create_table!
    # Tag.create_table!
    # BaseSchema.apply DB, :up
    # AddStupidColumn.apply DB, :up
  end
  
  task :remigrate do
    # BaseSchema.apply DB, :down
    # BaseSchema.apply DB, :up
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