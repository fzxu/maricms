class Page
  include Mongoid::Document
  
  field :slug
  field :title
  field :js_paths, :type => Array  #page based javascript include path
  field :css_paths, :type => Array
  
  references_many :ds, :stored_as => :array, :inverse_of => :pages
  embeds_many :page_metas
  
  validates_presence_of :slug
  validates_uniqueness_of :slug
end
