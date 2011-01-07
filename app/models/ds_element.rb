class DsElement
  include Mongoid::Document
  
  field :key
  field :name
  field :type, :default => "String"
  
  embedded_in :d, :inverse_of => :ds_elements
  
  validates_presence_of :key
  validates_presence_of :name
  validates_uniqueness_of :key
end