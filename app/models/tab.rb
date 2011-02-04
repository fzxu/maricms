class Tab
  include Mongoid::Document
  include Mongoid::Tree
  include Mongoid::Tree::Ordering

  field :slug
  field :name
  field :description
  field :hidden, :type => Boolean

  references_one :page

  validates_presence_of :name
  validates_presence_of :slug
  validates_uniqueness_of :slug

  before_destroy :move_children_to_parent

  def to_param
    self.slug
  end

end
