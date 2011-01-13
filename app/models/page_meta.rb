class PageMeta
  include Mongoid::Document
  
  field :http_equiv
  field :content
  
  embedded_in :page
  
  validates_presence_of :http_equiv
  validates_presence_of :content
end
