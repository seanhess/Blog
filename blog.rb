# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'sinatra/base'
require 'erb'
require 'controllers'
require 'data/init'
require 'sass'

class Blog < Sinatra::Base
  
  PostsPerPage = 10
  
  def initialize
    super
  end
  
  get '/' do
    @posts = get_posts
    erb :posts_list
  end
  
  get '/tag/:name' do
    @tag = Tag[:name => params[:name]]
    pass if @tag.nil?

    @posts = @tag.posts
    erb :posts_list
  end

  get '/:post' do
    @post = get_post params[:post]
    pass if @post.nil?
    erb :post_list, :locals => {:post => @post}
  end
  
  get '/css/main.css' do
    content_type 'text/css', :charset => 'utf-8' 
    sass :main
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