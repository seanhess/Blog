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
    @posts = get_posts_page
    erb :posts_list
  end
  
  get '/posts.rss' do
    @posts = get_posts_page
    erb :rss, :layout => false
  end

  get '/tag/:name' do
    @tag = Tag[:name => params[:name]]
    pass if @tag.nil?
    @posts = @tag.posts
    erb :tag
  end
  
  get '/archive' do
    @posts = get_posts
    @title = "Archive"
    erb :archive
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
      "/" + post.name
    end
    
    def full_post_url(post)
      "http://" + request.host + post_url(post)
    end
    
    def post_date(post)
      post.created.strftime "%B %d, %Y"
    end
    
    def post_guid(post)
      full_post_url post
    end
    
    def archive_post_date(post)
      post.created.strftime "%B %Y"
    end
    
    def rss_date(time)
      time.strftime("%a, %d %b %Y %H:%M:%S %Z")
    end
    
    def a_helper
      "help"
    end
  end
  
  
  
  
  
  
  
  def get_posts_page(page=0)
    get_posts.limit(PostsPerPage, PostsPerPage*page)
  end
  
  def get_posts
    Post.filter(:kind => Post::Post).reverse_order(:created)
  end

  def get_post(name)
    Post[:name => name.to_s]
  end
  
  
end