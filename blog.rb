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
    @posts = get_posts
    erb :posts
  end

  get '/:url' do
    @post = get_post params[:url]
    pass if @post.nil?
    erb :post, :locals => {:post => @post}
  end
  
  get '/*' do
    erb :not_found
  end
  
  
  
  
  
  
  
  
  
  def get_posts(page=0)
    Post.filter(:type => Post::Post).limit(PostsPerPage, PostsPerPage*page)
  end

  def get_post(url)
    Post[:url => url.to_s]
  end
  
  
end