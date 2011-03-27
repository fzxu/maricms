class DsSingle
  include Mongoid::Document
  
  references_one :mg_url, :as => :record, :autosave => true
end
