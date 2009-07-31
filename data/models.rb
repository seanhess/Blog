require 'rubygems'
require 'sequel'
require 'maruku'

class Post < Sequel::Model
  Page = "page"
  Post = "post"
  
  many_to_many :tags
  one_to_many :comments
  
  def date
    created.strftime "%B %d, %Y"
  end
  
  def summary(length=300)
    body.gsub(/(<[^>]*>)|\n|\t/s," ")[0..length]
  end
  
  def update_title(value)
    
    raise "[ ! ] Could not find title for post" if value.nil?
    
    self.title = value
    self.name = value.downcase.gsub(/[^\w]/,"_").gsub(/__/,"")
  end
end

class Tag < Sequel::Model
  many_to_many :posts, :order => :created.desc
end

class Comment < Sequel::Model
  many_to_one :posts
  
  def post
    Post[:id => post_id]
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
    Post.delete
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
      post = Post[:file => file] || Post.new
      if post.mtime.nil? || mtime > post.mtime


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
        post.update_title meta[:title]
        
        post.save
        post.remove_all_tags
        
        unless meta[:tags].nil?
          tags = meta[:tags].split /\s*,\s*/
          tags.each do |t|
            tag = Tag[:name => t]
            tag = Tag.create(:name => t) if tag.nil?
            post.add_tag tag unless post.tags.include? tag
          end
        end

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






