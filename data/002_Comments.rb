
require 'data/models'

class Comments < Sequel::Migration
  def up
    create_table! :comments do
      primary_key :id
      foreign_key :post_id, :posts
      
      String :name
      String :email
      String :url
      Text :body
    end
  end
  
  def down
    drop_table :comments
  end
end