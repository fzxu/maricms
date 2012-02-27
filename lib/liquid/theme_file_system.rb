module Liquid
  # This implements an abstract file system which retrieves template files named in a manner similar to Rails partials,
  # ie. with the template name prefixed with an underscore. The extension ".liquid" is also added.
  #
  # For security reasons, template paths are only allowed to contain letters, numbers, and underscore.
  #
  # Example:
  #
  # file_system = Liquid::LocalFileSystem.new("/some/path")
  # 
  # file_system.full_path("mypartial.html")       # => "/some/path/mypartial.html"
  # file_system.full_path("dir/mypartial")   # => "/some/path/dir/mypartial"
  #
  class ThemeFileSystem
    attr_accessor :root
    
    def initialize(root)
      @root = root
    end
    
    def read_template_file(template_path, context)
      full_path = full_path(template_path)
      raise FileSystemError, "No such template '#{template_path}'" unless File.exists?(full_path)
      
      File.read(full_path)
    end
    
    def full_path(template_path)
      full_path = if template_path.include?('/')
        File.join(root, File.dirname(template_path), "#{File.basename(template_path)}")
      else
        File.join(root, "#{template_path}")
      end
      
      raise FileSystemError, "Illegal template path '#{File.expand_path(full_path)}'" unless File.expand_path(full_path) =~ /^#{File.expand_path(root)}/
      
      full_path
    end
  end
end