class DsTab
  include Mongoid::Document
  include Mongoid::Tree
  include Mongoid::Tree::Ordering
  include Mongoid::Tree::Traversal

  field :slug
  field :name

	index :slug, :unique => true
	
  referenced_in :page#, :autosave => true

  validates_presence_of :name
  validates_presence_of :slug
  validates_uniqueness_of :slug

  before_destroy :move_children_to_parent

  # def to_param
  #   self.slug
  # end

	def to_liquid
		{
			"slug" => self.slug,
			"name" => self.name,
			"root?" => self.root?,
			"leaf?" => self.leaf?,
			"parent" => self.parent,
			"children" => self.children,
			"depth" => self.depth
		}
	end
end
