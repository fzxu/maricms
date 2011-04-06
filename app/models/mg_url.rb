class MgUrl
  include Mongoid::Document
  
  referenced_in :record, :polymorphic => true
  
  field :path
  
  field :param_string
  
  referenced_in :page
  
  validates_uniqueness_of :path
  validates_format_of :path, :with => /\A([\w]+)\z/
  
  def to_liquid
    {
      "id" => self.id.to_s,
      "path" => self.path,
      "record" => self.record,
      "param_string" => self.param_string,
      "page" => self.page
    }
  end
end
