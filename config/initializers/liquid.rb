class Liquid::ThemeFileSystem
  attr_accessor :root
  def initialize(root)
    @root = root
  end

  def read_template_file(context, template_name)
    template_path = context[template_name]
    full_path = full_path(template_path)
    raise Liquid::FileSystemError, "No such template '#{template_path}'" unless File.exists?(full_path)

    File.read(full_path)
  end

  def full_path(template_path)
    raise Liquid::FileSystemError, "Illegal template name '#{template_path}'" unless template_path =~ /^[^.\/][\.a-zA-Z0-9_\/]+$/

    full_path = if template_path.include?('/')
      File.join(root, File.dirname(template_path), "#{File.basename(template_path)}")
    else
      File.join(root, "#{template_path}")
    end
    puts "the full path is:"+full_path.to_s

    raise Liquid::FileSystemError, "Illegal template path '#{File.expand_path(full_path)}'" unless File.expand_path(full_path) =~ /^#{File.expand_path(root)}/

    full_path
  end
end