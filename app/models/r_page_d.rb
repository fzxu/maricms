class RPageD
  # this is the relationship between page and ds
  
  include Mongoid::Document
  
  field :query_hash, :type => Hash
  
  referenced_in :d
  embedded_in :page
end
