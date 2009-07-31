
require 'data/models'

class CommentCreated < Sequel::Migration
  def up
    alter_table :comments do
      add_column :created, :time
    end
  end
  
  def down
    alter_table :comments do
      remove_column :created
    end
  end
end