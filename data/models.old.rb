require 'rubygems'
require 'dm-core'
require 'dm-more'
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
  
  has_tags_on :tags

  property :id, Serial
  property :title, Text
  property :body, Text
  property :mtime, Time
  property :created, Time
  property :type, String, :default => Post
  property :url, String
  
  def import(url, content, tags)
    self.mtime = Time.now
    self.url = url
    self.body = content
    self.created = Time.now if self.created.nil?    
    tags.each do |t|
      tag = Tag.first(:name => t)
      
      tag = Tag.new({:name => t}) if tag.nil?
      
      self.tags << tag
    end
    save
  end
  
  
  def self.get_url(value)
    ## Extract Tags
    tags = []
    value = value.gsub /\((\w+)\)/ do |tag|
      tags << $1
      ""
    end

    ## Fix URL
    value.gsub! /\.(m|mark)down/, ""
    value.gsub! /(posts|pages)\//, ""
    value.gsub! /\s+/, "_"
    value.gsub! /[^\w\d\/]+/, ""
    
    [value, tags]
  end
end
