class DsSingle
  include Mongoid::Document
  
  references_one :mg_url, :as => :record, :autosave => true
  
  def to_liquid
    {
      "id" => self.id.to_s,
      "alias" => self.mg_url
    }
  end
end
