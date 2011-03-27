class Page
  include Mongoid::Document
  include Mongoid::Tree
  include Mongoid::Tree::Ordering
  include Mongoid::Tree::Traversal
  
  field :name
  field :theme_path
  field :per_page, :type => Integer, :default => 20
    
  embeds_many :r_page_ds
  embeds_many :page_metas
  
  references_one :mg_url, :as => :record, :autosave => true
  
  validates_presence_of :name
  
  before_destroy :move_children_to_parent
  
end
