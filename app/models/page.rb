class Page
  include Mongoid::Document
  
  field :slug
  field :title
  field :js_paths, :type => Array  #page based javascript include path
  field :css_paths, :type => Array
  field :theme_path
  
  index :slug, :unique => true
  
  references_and_referenced_in_many :ds
  embeds_many :page_metas
  referenced_in :tab
  
  validates_presence_of :slug
  validates_uniqueness_of :slug
  
  def to_param
    self.slug
  end
end
