# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'sinatra/base'
require 'erb'
require 'controllers'
require 'data/init'

class Blog < Sinatra::Base
  
  PostsPerPage = 10
  
  def initialize
    super
  end
  
  get '/' do
    posts
  end

  get '/:url' do
    post params[:url]
  end
  
  
  
  
  
  
  
  
  
  
  
  def posts(page=0)
    
    # :limit => PostsPerPage, :offset => PostsPerPage * page, 
    @posts = Post.filter(:type => Post::Post).limit(PostsPerPage, PostsPerPage*page)
    erb :posts
  end

  def post(url)
    @post = Post[:url => url.to_s]
    erb :post, :locals => {:post => @post}
  end
  
  
end