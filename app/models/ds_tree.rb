class DsTree
  include Mongoid::Document
  include Mongoid::Tree
  include Mongoid::Tree::Ordering
  include Mongoid::Tree::Traversal

  has_one :mg_url, :as => :record, :autosave => true
  field :mg_name, :type => String
  
  validates_presence_of :mg_name
  
  before_destroy :move_children_to_parent
  
  def to_liquid
    {
      "id" => self.id.to_s,
      "alias" => self.mg_url,
      "root?" => self.root?,
      "leaf?" => self.leaf?,
      "parent" => self.parent,
      "children" => self.children,
      "depth" => self.depth
    }
  end
end
