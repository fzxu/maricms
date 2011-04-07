class EditorAttachment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :asset_filesize,:type => Integer
  field :asset_contenttype, :type => String
  
  mount_uploader :asset, EditorUploader
end
