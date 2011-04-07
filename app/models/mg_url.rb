class MgUrl
  include Mongoid::Document
  
  belongs_to :record, :polymorphic => true
  
  field :path, :type => String
  
  field :param_string, :type => String
  
  belongs_to :page
  
  validates_uniqueness_of :path
  validates_format_of :path, :with => /\A([\w]+)\z/
  
  index :path, :unique => true
  
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
