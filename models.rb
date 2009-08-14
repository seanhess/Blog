require 'rubygems'
require 'couchrest'
require 'maruku'

class Couch
  DB = "blog"
  Server = CouchRest.new
  
  def self.connect
    Server.default_database = self::DB
  end
  
  def self.db
    Server.default_database
  end
  
  def self.delete!
    Server.default_database.delete!
  end
end

Couch.connect

class Post < CouchRest::ExtendedDocument
  use_database Couch.db
  unique_id :name
  
  Page = "page"
  Post = "post"
  
  property :title
  property :body
  property :mtime
  property :created
  property :kind, :default => "post"
  property :file
  property :name
  property :tags
  
  view_by :name
  view_by :file
  view_by :kind, :created, :descending => true
  view_by :kind
  
  view_by :tags, :map => "
    function(doc) {
      if (doc.tags) {
        doc.tags.forEach(function(tag) {
          emit(tag, 1);    
        });
      }
    }",

  :reduce => "
    function(keys, values, rereduce) {
      return sum(values);
    }"
    
  view_by :tag, :map => "
    function(doc) {
      if (doc.tags)
        for (var i in doc.tags)
          emit(doc.tags[i].toLowerCase(), doc.name);

    }"
  
  def self.tag_counts
    all_tags = self.by_tags(:raw => true, :group => true, :reduce => true)['rows']
    all_tags.map! {|row| {:name => row['key'], :count => row['value']}}
    all_tags.sort! {|a, b| b[:count] <=> a[:count]}
  end
  
  def self.tag_posts tag
    self.by_tag(:key => tag)
  end
  
  def tags
    self['tags'] || ["Hello"]
  end
  
  def self.get_first_ten
    self.by_kind_and_created(:startkey => [self::Post, {}], :endkey => [self::Post,nil], :limit => 10)
  end
  
  def self.all_posts
    self.by_kind_and_created(:startkey => [self::Post, {}], :endkey => [self::Post,nil])
  end
  
  def remove_all_tags
    tags = []
  end
  
  def comments
    Comment.post_comments name
  end
  
  def date
    Time.parse(created)
  end
    
  def summary(length=300)
    body.gsub(/(<[^>]*>)|\n|\t/s," ")[0..length]
  end  
  
  def first_paragraph()
    body.gsub(/^(.*?)<\/p>.*$/mis,'\1')
  end
end

class Comment < CouchRest::ExtendedDocument
  use_database Couch.db
  
  property :name
  property :email
  property :url
  property :body
  property :post_name
  property :created
  
  view_by :post_name, :created
  view_by :created
  
  def date
    Time.parse(created)
  end
  
  def self.post_comments name
    self.by_post_name_and_created :startkey => [name,nil], :endkey => [name,{}]
  end
  
  def post= post
    self['post_name'] = post.name
  end
  def post
    Post.get(post_name) if post_name
  end
end


class PostParser
  
  def self.parse_meta(content)
    meta = {}
    
    content = content.sub /^(.*?)\n\n/m do |meta_content|
      meta[:title] = meta_value :title, meta_content
      meta[:tags] = meta_value :tags, meta_content
      meta[:date] = meta_value :date, meta_content
      ""
    end
        
    [content, meta]
  end
  
  def self.meta_value(name, meta_content)
    reg = Regexp.new "#{name}: (.*)", "i"
    match = reg.match meta_content 
    match ? match[1] : nil
  end



  
  
  ## SCANNING ##
  def self.trim
    posts = Post.all.each do |post|
      unless File.exists? post.file
        puts "Destroyed: #{post.file}"
        post.destroy
      end
      
    end
  end
  
  def self.nuke
    Couch.delete!
    Couch.connect
  end
  
  def self.scan_posts
    scan "posts"
  end
  
  def self.scan_pages
    scan "pages", true
  end
  
  def self.scan (dir, is_page = false)
    scan_markdown_header
    
    # Scan directories for files
    Dir.glob(File.join(dir,"**","*.markdown")) do |file|    

      # See if it exists or has changed
      mtime = File.mtime(file)
      post = Post.by_file(:key => file).first || Post.new
      if post.mtime.nil? || mtime > Time.parse(post.mtime)


        # Read the file
        f = File.new file, "r"        
        content, meta = parse_meta f.read        
        
        puts "[ ! ] Metadata block missing - #{file}" if meta[:title].nil?
        
        markdown_content = @markdown_header + "\n\n" + content
        
        html_content = Maruku.new(markdown_content).to_html

        # Set the values
        post.body = html_content
        post.mtime = Time.now
        post.created = Time.now if post.created.nil?
        post.created = Time.parse meta[:date] unless meta[:date].nil?
        post.kind = Post::Page if is_page
        post.file = file
        post.title = meta[:title]
        post.name = File.basename(file, ".markdown").downcase.gsub(/[^\w]/,"_").gsub(/__/,"_")
        
        post.remove_all_tags
        
        unless meta[:tags].nil?
          tags = meta[:tags].split /\s*,\s*/
          post.tags = tags
        end

        post.save

        puts "Updated: #{file}"
        
        # TODO: Mark cache invalidation #
      end    
    end
  end
  
  def self.scan_markdown_header
    if @markdown_header.nil?
      @markdown_header = File.new(File.join(Dir.pwd,"/pages/header.mdown"), "r").read
    end
    
    @markdown_header
  end
end







