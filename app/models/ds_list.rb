class DsList
  include Mongoid::Document
  include Mongoid::Orderable
  
  has_one :mg_url, :as => :record
end
