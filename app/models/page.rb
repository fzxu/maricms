class Page
  include Mongoid::Document
  include Mongoid::Tree
  include Mongoid::Tree::Ordering
  include Mongoid::Tree::Traversal
  
  field :name, :type => String
  field :theme_path, :type => String
  field :per_page, :type => Integer, :default => 20
    
  embeds_many :r_page_ds
  embeds_many :page_metas
  
  has_one :mg_url, :as => :record, :autosave => true
  
  validates_presence_of :name
  
  before_destroy :move_children_to_parent
  
  def to_liquid
    {
      "id" => self.id.to_s,
      "name" => self.name,
      "alias" => self.mg_url,
      "root?" => self.root?,
      "leaf?" => self.leaf?,
      "parent" => self.parent,
      "children" => self.children,
      "depth" => self.depth      
    }
  end
end
