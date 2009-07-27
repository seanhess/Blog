require 'rubygems'
require 'data/init'
require 'maruku'

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
    
    # puts File.join(dir, "*.markdown")
    
    Dir.glob(File.join(dir,"**","*.markdown")) do |file|      

      # key the url: key
      url, tags = Post.get_url file
      
      mtime = File.mtime(file)

      # see if it exists
      post = Post[:url => url] || Post.new
      
      if post.mtime.nil? || mtime > post.mtime
        f = File.new file, "r"
        
        markdown_content = @markdown_header + f.read
        
        html_content = Maruku.new(markdown_content).to_html
        
        post.type = Post::Page if is_page

        post.import url, html_content, tags
        puts "Updated: #{url}"
        
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