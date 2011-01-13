class Tab
  include Mongoid::Document
  #include Mongoid::Tree
  #include Mongoid::Tree::Ordering
  

  field :name
  field :description
  field :hidden, :type => Boolean

  references_one :page
  
  validates_presence_of :name
  
  #before_destroy :move_children_to_parent
end
