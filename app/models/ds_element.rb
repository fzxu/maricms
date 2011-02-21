class DsElement
  include Mongoid::Document
  
  field :key
  field :name
  field :ftype, :default => "String"
  field :unique, :type => Boolean, :default => false
  field :notnull, :type => Boolean, :default => false
  
  embedded_in :d
  
  validates_presence_of :key
  validates_presence_of :name
  validates_uniqueness_of :key
end
