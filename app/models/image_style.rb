class ImageStyle
  include Mongoid::Document
  
  field :key
  field :name
  
  field :width, :type => Integer
  field :height, :type => Integer
  #field :format
  field :quality, :type => Integer
  field :crop, :type => Boolean
  
  validates_presence_of :key
  validates_presence_of :name
  validates_uniqueness_of :key
  validates_format_of :key, :with => /\A([A-Za-z][\w]+)\z/
  
  recursively_embeds_many
  
  # regenerate the Class on the fly when changed
  after_save :gen_uploader_klass, :regenerate_related_d_klass
  
  before_destroy :remove_ds_element_relation, :destroy_uploader_klass, :regenerate_related_d_klass
  
  def gen_uploader_klass
    class_name = gen_class_name
    
    # Need to recreate the klass even it is exist, because it has been changed
    Object.class_eval do
      begin
        const_get(class_name)
        remove_const(class_name)
      rescue NameError
      end
    end
    GC.start

    # generate the class const and inherit the ImageUploader class
    klass = Object.const_set(class_name, Class.new(ImageUploader))

    # can find the related image style from the uploader
    meta_string = ""
    liquid_string = ""
    
    # add the parent image style    
    meta_string += <<-PARENT_STYLE          
      process :#{get_resize_string(self.crop)} => [#{self.width}, #{self.height}]
      process :quality => #{self.quality}

      # default one used by datatable
      version :mg_small do
        process :resize_to_fill => [80, 55]
        process :quality => 90
      end
      
      def extension_white_list
        %w(jpg jpeg gif png)
      end
          
    PARENT_STYLE
    
    liquid_string += " 'url' => self.url, \n"
    
    # add all the versions
    self.child_image_styles.each do |version|
      meta_string += <<-VERSION
        version :#{version.key} do
          process :#{get_resize_string(version.crop)} => [#{version.width}, #{version.height}]
          process :quality => #{version.quality}
        end      
      VERSION
      liquid_string += " '#{version.key}_url' => self.#{version.key}.url, \n"
    end
    
    liquidinj = <<-LIQUIDINJ
      def to_liquid
        ret = { #{liquid_string} }
        if self.class.superclass.method_defined?("to_liquid")
          ret = ret.merge super
        end
        ret
      end
    LIQUIDINJ
    meta_string = meta_string + liquidinj
    klass.class_eval(meta_string)
    
    klass.image_style = self
    klass
  end

  def get_uploader_klass
    class_name = gen_class_name

    #check whether the class is already exist
    begin
      klass = Object.const_get(class_name)
      if klass.is_a?(Class)
      return klass
      end
    rescue NameError
    #do nothing
    end

    #ok. it does not exist, try to create it
    gen_uploader_klass
  end
  
  private
  
  def get_resize_string(crop = false)
    resize_string = "resize_to_limit"
    if crop
      resize_string = "resize_to_fill"
    end
    resize_string 
  end
  
  def gen_class_name
    EXT_CLASS_PREFIX + self.key.capitalize + "Uploader"
  end
  
  def remove_ds_element_relation
    # loop all the pages and delete the related refs
    D.all.each do |d|
      d.ds_elements.each do |ds_element|
        if ds_element.image_style && ds_element.image_style.id == self.id
          ds_element.update_attributes(:image_style => nil)
          break
        end
      end
    end
  end
  
  # in case the image style is changed, force the d to regenerate
  def regenerate_related_d_klass
    D.all.each do |d|
      d.ds_elements.each do |ds_element|
        if ds_element.image_style && ds_element.image_style.id == self.id
          d.gen_klass
          break
        end
      end
    end    
  end
  
  def destroy_uploader_klass
    class_name = gen_class_name
    
    # Need to recreate the klass even it is exist, because it has been changed
    Object.class_eval do
      begin
        const_get(class_name)
        remove_const(class_name)
      rescue NameError
      end
    end
    GC.start    
  end
end