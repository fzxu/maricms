class Page
  include Mongoid::Document
  
  field :slug
  field :name
  
  references_many :ds, :stored_as => :array, :inverse_of => :pages
  
  validates_presence_of :slug
  validates_uniqueness_of :slug
end
