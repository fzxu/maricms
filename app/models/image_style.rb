class ImageStyle
  include Mongoid::Document
  
  field :key
  field :name
  
  field :width, :type => Integer
  field :height, :type => Integer
  field :format, :default => "jpg"
  field :crop, :type => Boolean
  
  validates_presence_of :key
  validates_presence_of :name
  validates_uniqueness_of :key
  validates_format_of :key, :with => /\A([A-Za-z][\w]+)\z/
  
  recursively_embeds_many
end
