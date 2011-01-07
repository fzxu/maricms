class D
  include Mongoid::Document
  
  # This model is for data source
  field :key
  field :name
  
  embeds_many :ds_elements
  references_many :pages, :stored_as => :array, :inverse_of => :ds
  
  validates_presence_of :key
  validates_uniqueness_of :key
  
  def get_klass
    class_name = "Data" + self.key.capitalize
    klass = Object.const_set(class_name,Class.new)
    
    meta_string = "include Mongoid::Document \n"
    liquid_string = ""
    self.ds_elements.each do |ds_element|
      meta_string = meta_string + "field :#{ds_element.key}, :type => #{ds_element.type} \n"
      liquid_string = liquid_string + "'#{ds_element.key}' => self.#{ds_element.key}, \n"
    end
    liquid_string = liquid_string[0..-4] + "\n" #remove the last ','
    
    liquidinj = <<LIQUIDINJ
    def to_liquid
      {
        #{liquid_string}
      }
    end
LIQUIDINJ
    meta_string = meta_string + liquidinj
    klass.class_eval(meta_string)
    klass
  end
end
