class DsTree
  include Mongoid::Document
  include Mongoid::Tree
  include Mongoid::Tree::Ordering
  include Mongoid::Tree::Traversal

  references_one :mg_url, :as => :record, :autosave => true
  
  before_destroy :move_children_to_parent

  def to_liquid
    {
      "root?" => self.root?,
      "leaf?" => self.leaf?,
      "parent" => self.parent,
      "children" => self.children,
      "depth" => self.depth
    }
  end
end
