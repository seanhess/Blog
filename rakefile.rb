require 'rake'
require 'data/init'
require 'sass'

namespace :db do 
  task :migrate do
    `sequel -m data data/database.yml`
  end
  
  task :wipe do
    `sequel -m data data/database.yml -M 0`
  end
  
end


namespace :cache do
  desc "Converts css"
  task :css do 
    `sudo rm -rf public/css/main.css`
    `sass views/main.sass public/css/main.css`
  end
end

namespace :scan do
  
  desc "Scan posts directory and import posts using maruku"
  task :posts do
    PostParser.scan_posts
  end
  
  desc "Scan pages directory and import posts using maruku"
  task :pages do
    PostParser.scan_pages
  end
  
  desc "Scan everything"
  task :all do
    PostParser.scan_posts
    PostParser.scan_pages
  end
  
  desc "Remove old posts"
  task :trim do
    PostParser.trim
  end
  
  desc "Remove all posts and rescan"
  task :nuke do
    PostParser.nuke
    PostParser.scan_posts
    PostParser.scan_pages
  end
end