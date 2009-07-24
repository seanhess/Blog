require 'rubygems'
require 'models'
require 'erb'

class Scan
  
  ## SCANNING ##
  def posts
    scan "posts"
  end
  
  def pages
    scan "pages", true
  end
  
  def scan (dir, is_page = false)
    scan_markdown_header
    
    Dir.glob(dir + "/*.markdown") do |file|
      name = File.basename file, ".markdown"
      mtime = File.mtime(file)
      post = Post.first(:name => name) || Post.new
      
      if post.mtime.nil? || mtime > post.mtime
        f = File.new file, "r"
        
        markdown_content = @markdown_header + f.read
        
        content = Maruku.new(markdown_content).to_html
        
        post.type = Post::Page if is_page
        
        post.import name, content
        puts "Updated: #{name}"
        
        # TODO: Mark cache invalidation #
      end    
    end
  end
  
  def scan_markdown_header
    if @markdown_header.nil?
      @markdown_header = File.new(File.expand_path(File.dirname(__FILE__) + "/pages/header.markdown"), "r").read
    end
    
    @markdown_header
  end
end