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
    class_name = "GoingToChange" + self.key.capitalize
    klass = Object.const_set(class_name,Class.new)
    
    meta_string = "include Mongoid::Document \n"
    self.ds_elements.each do |ds_element|
      meta_string = meta_string + "field :#{ds_element.key}, :type => #{ds_element.type} \n"
    end
    klass.class_eval(meta_string)
    klass
  end
end
