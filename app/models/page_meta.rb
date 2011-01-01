class PageMeta
  include Mongoid::Document
  
  field :http_equiv
  field :content
  
  embedded_in :page, :inverse_of => :page_metas
  
  validates_presence_of :http_equiv
  validates_presence_of :content
end
