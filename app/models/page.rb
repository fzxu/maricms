class Page
  include Mongoid::Document
  
  field :slug
  field :title
  field :js_paths, :type => Array  #page based javascript include path
  field :css_paths, :type => Array
  field :theme_path
  field :head_yield
  
  index :slug, :unique => true
  
  references_and_referenced_in_many :ds
  embeds_many :page_metas
  
  #references_many :tabs, :autosave => true
  
  validates_presence_of :slug
  validates_uniqueness_of :slug
  
  def to_param
    self.slug
  end
end
