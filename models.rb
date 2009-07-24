require 'rubygems'
require 'dm-core'
require 'maruku'

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
  property :name, String, :key => true
  property :body, Text
  property :mtime, Time
  property :created, Time
  property :type, String, :default => Post
  
  def import(name, content)
    self.name = name
    self.body = content
    self.mtime = Time.now
    self.created = Time.now if self.created.nil?    
    save
  end
end

class Tag
  include DataMapper::Resource 
  
  has n, :taggings
  has n, :posts, :through => :taggings
  
  property :id, Serial
  property :name, String, :key => true
end

class Tagging
  include DataMapper::Resource 
  
  belongs_to :post
  belongs_to :tag
  
  property :id, Serial
end