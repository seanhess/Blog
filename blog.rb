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
  
  get '/feeds/posts' do
    @posts = get_posts_page
    @rss_link = "/"
    content_type 'application/rss+xml'
    erb :rss, :layout => false
  end
  
  get '/feeds/:tag' do
    @posts, @tag = get_tag_posts params[:tag]
    @rss_link = "/tag/" + params[:tag]
    content_type 'application/rss+xml'
    erb :rss, :layout => false
  end
  
  get '/tag/:name' do
    @posts, @tag = get_tag_posts params[:name]
    pass if @posts.empty?
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
  

  
  private
  
  def get_tag_posts(name)
    tag = Tag[:name => name]
    
    if tag.nil?
      [[], nil]
    else
      [tag.posts, tag]
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
  
  
  
  
  
  
  
  
  helpers do 
    
    def tag_url(tag)
      "/tag/" + tag.name.downcase
    end
    
    def tag_feed_url(tag)
      "/feeds/" + tag.name.downcase
    end
    
    def post_url(post)
      "/" + post.name
    end
    
    def full_url(url)
      "http://" + request.host + url
    end
    
    def post_date(post)
      post.created.strftime "%B %d, %Y"
    end
    
    def post_guid(post)
      full_url(post_url(post))
    end
    
    def archive_post_date(post)
      post.created.strftime "%B %Y"
    end
    
    def rss_date(time)
      time.strftime("%a, %d %b %Y %H:%M:%S %Z")
    end
  end
  
  
  
end