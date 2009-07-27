require 'rubygems'
require 'sequel'

class Post < Sequel::Model(:posts)
  Page = "page"
  Post = "post"
  
  many_to_many :tags

  def import(url, content, tags)
    self.mtime = Time.now
    self.url = url
    self.body = content
    self.created = Time.now if self.created.nil?    
    save
    
    tags.each do |t|
      tag = Tag[:name => t]
      
      tag = Tag.create(:name => t) if tag.nil?
      
      self.add_tag tag
    end
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

class Tag < Sequel::Model(:tags)
  many_to_many :posts
end







