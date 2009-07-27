# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'sinatra/base'
require 'erb'
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
    
    if @post.kind == Post::Page
      erb :page, :locals => {:post => @post}
    else
      erb :post_full, :locals => {:post => @post}      
    end
    
  end
  
  get '/css/main.css' do
    content_type 'text/css', :charset => 'utf-8' 
    sass :main
  end
  
  get '/*' do
    erb :not_found
  end
  
  helpers do 
    def post_url(post)
      post.name
    end
    
    def a_helper
      "help"
    end
  end
  
  
  
  
  
  
  
  
  
  def get_posts(page=0)
    Post.filter(:kind => Post::Post).limit(PostsPerPage, PostsPerPage*page)
  end

  def get_post(name)
    Post[:name => name.to_s]
  end
  
  
end