class DsStandard
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Orderable
  
  has_one :mg_url, :as => :record
end
