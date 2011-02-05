class Tab
  include Mongoid::Document
  include Mongoid::Tree
  include Mongoid::Tree::Ordering

  field :slug
  field :name
  field :description
  field :param_string
  field :hidden, :type => Boolean

  references_one :page, :autosave => true

  validates_presence_of :name
  validates_presence_of :slug
  validates_uniqueness_of :slug

	validates_presence_of :page
	
  before_destroy :move_children_to_parent

  def to_param
    self.slug
  end

end
