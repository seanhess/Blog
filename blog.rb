# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'sinatra/base'
require 'erb'
require 'controllers'
require 'models'

class Blog < Sinatra::Base
  
  PostsPerPage = 10
  
  def initialize
    super
  end
  
  get '/' do
    posts
  end

  get '/about' do
    post :about
  end
  
  get '/contact' do
    post :contact
  end
  
  get '/code' do
    post :code
  end
  
  
  
  
  
  
  
  
  
  
  
  def posts(page=0)
    @posts = Post.all(:limit => PostsPerPage, :offset => PostsPerPage * page, :type => Post::Post)
    erb :posts
  end

  def post(name)
    @post = Post.first(:name => name.to_s)
    erb :post
  end
  
  
end