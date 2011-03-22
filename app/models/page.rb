class Page
  include Mongoid::Document
  include Mongoid::Tree
  include Mongoid::Tree::Ordering
  include Mongoid::Tree::Traversal
  
  field :slug
  field :name
  field :js_paths, :type => Array  #page based javascript include path
  field :css_paths, :type => Array
  field :theme_path
  field :head_yield
  field :per_page, :type => Integer, :default => 20
  
  index :slug, :unique => true
  
  embeds_many :r_page_ds
  embeds_many :page_metas
  
  
  validates_presence_of :slug
  validates_uniqueness_of :slug
  validates_presence_of :name
  
  before_destroy :move_children_to_parent
  
  def to_param
    self.slug
  end
end
