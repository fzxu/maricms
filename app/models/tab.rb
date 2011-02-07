class Tab
  include Mongoid::Document
  include Mongoid::Tree
  include Mongoid::Tree::Ordering
  include Mongoid::Tree::Traversal

  field :slug
  field :name
  field :description
  field :param_string
  field :hidden, :type => Boolean
  field :ref_url
  field :open_in_new_window, :type => Boolean

  references_one :page, :autosave => true

  validates_presence_of :name
  validates_presence_of :slug
  validates_uniqueness_of :slug

  before_destroy :move_children_to_parent

  def to_param
    self.slug
  end

	def to_liquid
		{
			"slug" => self.slug,
			"name" => self.name,
			"description" => self.description,
			"param_string" => self.param_string,
			"hidden" => self.hidden,
			"ref_url" => self.ref_url,
			"open_in_new_window" => self.open_in_new_window,
			"root?" => self.root?,
			"leaf?" => self.leaf?,
			"parent" => self.parent,
			"children" => self.children,
			"depth" => self.depth
		}
	end
end
