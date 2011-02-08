class D
  include Mongoid::Document

  # This model is for data source
  field :key
  field :name

  embeds_many :ds_elements
  references_and_referenced_in_many :pages

  validates_presence_of :key
  validates_uniqueness_of :key

  after_save :gen_klass
  
  def gen_klass
  	# Need to recreate the klass even it is exist, because it has been changed
  	
    class_name = "Data" + self.key.capitalize
    
    Object.class_eval do
    	begin
    		const_get(class_name)
      	remove_const(class_name)
     	rescue NameError
     	end 
    end
    GC.start
    
    klass = Object.const_set(class_name,Class.new)

    meta_string = "include Mongoid::Document \n include Mongoid::Paperclip \n"
    liquid_string = ""
    self.ds_elements.each do |ds_element|
      if ds_element.type == "File"
        meta_string = meta_string + "has_attached_file :#{ds_element.key} \n"
      elsif ds_element.type == "Image"
        meta_string = meta_string + <<-IMAGEMETA
        	has_attached_file :#{ds_element.key},
        	:styles => {
      			:original => ['1920x1680>', :jpg],
      			:small    => ['100x100#',   :jpg],
      			:medium   => ['250x250',    :jpg],
      			:large    => ['500x500>',   :jpg]
    			}
    			
        IMAGEMETA
      elsif ds_element.type == "Text"
        meta_string = meta_string + "field :#{ds_element.key}, :type => String \n"
      else
        meta_string = meta_string + "field :#{ds_element.key}, :type => #{ds_element.type} \n"
      end
      liquid_string = liquid_string + "'#{ds_element.key}' => self.#{ds_element.key}, \n"
    end
    liquid_string = liquid_string[0..-4] + "\n" #remove the last ','

    liquidinj = <<-LIQUIDINJ
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

  def get_klass
    class_name = "Data" + self.key.capitalize

    #check whether the class is already eval
    begin
      klass = Object.const_get(class_name)
      if klass.is_a?(Class)
      	return klass
      end
    rescue NameError
    #do nothing
    end

    #ok. it is not evaled, try to create it
    gen_klass
  end
end
