class EditorAttachment
  include Mongoid::Document
  #include Mongoid::Paperclip
  include Mongoid::Timestamps

  field :asset_filesize,:type => Integer
  field :asset_contenttype
  
  mount_uploader :asset, EditorUploader
end
