require 'rake'
require 'data/init'

namespace :db do 
  task :migrate do
    `sequel -m data data/database.yml`
  end
  
  task :wipe do
    `sequel -m data data/database.yml -M 0`
  end
  
end


namespace :scan do
  
  desc "Scan posts directory and import posts using maruku"
  task :posts do
    PostParser.scan_posts
  end
  
  task :pages do
    PostParser.scan_pages
  end
  
  task :all do
    PostParser.scan_posts
    PostParser.scan_pages
  end
end