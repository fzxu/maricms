class MgUrl
  include Mongoid::Document
  
  belongs_to :record, :polymorphic => true
  
  field :path
  
  field :param_string
  
  referenced_in :d
  referenced_in :page
  
  validates_uniqueness_of :path
  validates_format_of :path, :with => /\A([\w]+)\z/
end
