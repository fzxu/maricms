class DsList
  include Mongoid::Document
  include Mongoid::Orderable
  
  references_one :mg_url, :as => :record, :autosave => true
end
