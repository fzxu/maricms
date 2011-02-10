class EditorAttachment
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps
  
  field :asset_updated_at,:type => DateTime

  has_mongoid_attached_file :asset,
          :styles => APP_CONFIG[:att_style],
          :convert_options => { :all => '-quality 100'}
          
  before_create :randomize_file_name
  
  private
   def randomize_file_name

     unless asset_file_name.nil?
       extension = File.extname(asset_file_name).downcase
       self.asset.instance_write(:file_name, "#{ActiveSupport::SecureRandom.hex(16)}#{extension}")
     end
   end
end
