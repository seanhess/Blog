require 'rubygems'
require 'dm-core'

DataMapper.setup(:default, {
    :adapter => "mysql",
    :database => "blog_test",
    :username => "root",
    :password => "root",
    :host => "localhost"
})

class Post
  include DataMapper::Resource
  
  Page = "page"
  Post = "post"
  
  has n, :taggings
  has n, :tags, :through => :taggings

  property :id, Serial
  property :body, Text
  property :mtime, Time
  property :created, Time
  property :type, String, :default => Post
  property :url, String
end

class Tag
  include DataMapper::Resource 
  
  has n, :taggings
  has n, :posts, :through => :taggings
  
  property :id, Serial
  property :name, String
end

class Tagging
  include DataMapper::Resource 
  
  belongs_to :post
  belongs_to :tag
  
  property :id, Serial
end






DataMapper.auto_migrate!

one = Tag.new
one.name = "one"
one.save

two = Tag.new
two.name = "two"
two.save

first = Post.new
first.body = "This is a body"
first.mtime = Time.now
first.created = Time.now
first.type = Post::Post
first.url = "a/url"
first.save

second = Post.new
second.body = "Two"
second.mtime = Time.now
second.created = Time.now
second.type = Post::Post
second.url = "b/url"
second.save

first.tags << one
first.tags << two

first.save

# 
# posts = Post.all
# 
# posts.each do |p|
#   puts "Post: #{p.url} - tags: #{p.tags.length}"
# end
# 
# reloaded_first = Post.first(1)[0]
# puts "Reloaded: #{reloaded_first.url} - tags: #{reloaded_first.tags.length}"

