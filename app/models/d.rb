class D
  include Mongoid::Document
  
  # This model is for data source
  field :name
  
  embeds_many :ds_elements
  
end
