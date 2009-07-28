
require 'data/models'

class BaseSchema < Sequel::Migration
  def up
    create_table! :posts do
      primary_key :id
      String :title
      Text :body
      Time :mtime
      Time :created
      String :kind, :default => Post::Post
      String :file
      String :name
    end
    
    create_table! :tags do 
      primary_key :id
      String :name
    end

    create_table! :posts_tags do
      primary_key :id
      foreign_key :tag_id, :tags
      foreign_key :post_id, :posts
    end      
  end
  
  def down
    drop_table :posts
    drop_table :tags
    drop_table :posts_tags
  end
end