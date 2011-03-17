class MgAlias
  include Mongoid::Document
  
  field :mg_alias
  field :record_id
  field :param_string
  
  referenced_in :d

  validates_uniqueness_of :mg_alias
  validates_format_of :mg_alias, :with => /\A([\w]+)\z/
end
