# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'sinatra/base'
require 'erb'
require 'data/init'
require 'digest/md5'

# require 'sass'

class Blog < Sinatra::Base
  
  PostsPerPage = 10
  
  def initialize
    @extra_title = "Blog"
    super
  end
  
  get '/' do
    @months = {}
    @posts = get_posts_page.all
    @first_post = @posts.shift
    erb :posts_list
  end
  
  get '/feeds/posts' do
    @posts = get_posts_page
    @rss_link = "/"
    @rss_type = "Posts"    
    content_type 'application/rss+xml'
    erb :rss_posts, :layout => :rss
  end
  
  get '/feeds/comments' do
    @comments = Comment.reverse_order(:id).all
    @rss_link = "/"
    @rss_type = "Comments"
    content_type 'application/rss+xml'
    erb :rss_comments, :layout => :rss
  end
  
  get '/feeds/:tag' do
    @posts, @tag = get_tag_posts params[:tag]
    @rss_link = "/tag/" + params[:tag]
    @rss_type = params[:tag]
    content_type 'application/rss+xml'
    erb :rss_posts, :layout => :rss
  end
  
  get '/tag/:name' do
    @extra_title = params[:name]
    @months = {}    
    @posts, @tag = get_tag_posts params[:name]
    pass if @posts.empty?
    erb :tag
  end
  
  get '/archive' do
    @extra_title = "archive"
    @months = {}
    @posts = Post.filter(:kind => Post::Post).reverse_order(:created)
    @title = "Archive"
    erb :archive
  end
  
  get '/tags' do
    @extra_title = "Tags"
    @tags = Tag.all.delete_if do |tag|
      tag.posts.length < 1
    end
    @tags.sort! do |a, b|
      b.posts.length <=> a.posts.length
    end
    erb :tags
  end

  post '/posts/:post/comments' do
    post = Post[:name => params[:post]]
    
    unless request[:check].downcase == "human"
      # redirect(post_url(post) << "/comment_error#comment_messages") 
      return "error"
    end
    
    comment = Comment.new
    comment.name = html_escape request[:name]
    comment.email = html_escape request[:email]
    comment.body = newlines_and_links(html_escape(request[:body]))
    comment.url = html_escape request[:url]
    comment.created = Time.now
    comment.save
    
    post.add_comment comment
    # redirect(post_url(post) << "/comment_success##{comment_tag comment}")
    erb :comment, :layout => false, :locals => {:c => comment}
  end
  
  

  get '/posts/:post*' do
    @post = get_post params[:post]
    pass if @post.nil?
    @extra_title = @post.title
    erb :post_full, :locals => {:post => @post}      
  end
  
  get '/:page' do
    @page = get_post params[:page]
    pass if @page.nil? || @page.kind == Post::Post
    @extra_title = @page.title    
    erb :page, :locals => {:post => @page}
  end
  
  ## This will be ignored if the file has been generated. See rake cache:css
  get '/css/main.css' do
    content_type 'text/css', :charset => 'utf-8' 
    sass :main
  end
  
  get '/*' do
    @extra_title = "Page not found"
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
    
    def html_escape(s)
      s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
    end
    
    def newlines_and_links(s)
      newlines = s.gsub(/\n/, '<br>')
      links = newlines.gsub(/(http:\/\/[\w\/\.\-\d]+)/, '<a href="\1">\1</a>')
    end
    
    def comment_tag(comment)
      "comment_#{comment.id.to_s}"
    end
    
    def comment_gravatar(comment)
      "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(comment.email)}&rating=PG"
    end
    
    def url_parts()
      request.path.split(/\//).join " "
    end
    
    def tag_url(tag)
      "/tag/" + tag.name.downcase
    end
    
    def tag_feed_url(tag)
      "/feeds/" + tag.name.downcase
    end
    
    def post_url(post)
      "/posts/" + post.name
    end
    
    def post_comments_url(post)
      post_url(post) << "/comments"
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
      return "" if time.nil?
      time.strftime("%a, %d %b %Y %H:%M:%S %Z")
    end
    
    # def form(url, method, &block)
    #       "hello"
    #       yield
    #       "ok"
    #     end
    
    def form(url, method, &block)
      @_out_buf << "<form action='#{url}' method='post'>"
      @_out_buf << "<input type='hidden' name='_method' value='#{method}'>"
      yield
      @_out_buf << "</form>"
    end
  end
  
  
  
end