module Paperclip
  class Attachment
    def to_liquid
      self
    end
  end
end

if Rails.env == "production"
  Paperclip.options[:command_path] = "/opt/ImageMagick/bin"
end
