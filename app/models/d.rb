class D
  include Mongoid::Document

  # This model is for data source
  field :key
  field :name
  field :time_log, :type => Boolean
  field :ds_type, :default => "List"
  field :ds_view_type, :default => "User"

  embeds_many :ds_elements

  index :key, :unique => true
  index "ds_elements.key"

  validates_presence_of :key
  validates_presence_of :name
  validates_presence_of :ds_type
  validates_uniqueness_of :key
  validates_format_of :key, :with => /\A([A-Za-z][\w]+)\z/

  scope :list, :where => {:ds_type => "List"}
  scope :tree, :where => {:ds_type => "Tree"}
  
  scope :developer_view, :where => {:ds_view_type => "Developer"}
  scope :user_view, :where => {:ds_view_type => "User"}
  
  # regenerate the Class on the fly when changed
  after_save :gen_klass
  before_destroy :remove_page_relation, :remove_collection, :destroy_klass
  
  def gen_klass
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

    # generate the class const and inherit the class with the name = ds_type
    klass = Object.const_set(class_name,Class.new(Object.const_get("Ds" + self.ds_type) || Object))
    
    # can find the related d from the ds record
    meta_string = <<-INIT
      cattr_accessor :d
    INIT

    if self.time_log
      meta_string += "\n include Mongoid::Timestamps \n"
    end


    liquid_string = ""
    
    self.ds_elements.each do |ds_element|
      # assemble the model based on the ftype
      if ds_element.ftype == "File"
        meta_string += "mount_uploader :#{ds_element.key}, FileUploader \n"
      elsif ds_element.ftype == "Image"
        
        # if the related image style has been deleted
        begin
          image_style = ImageStyle.find(ds_element.image_style_id)
        rescue
        end
        meta_string += "mount_uploader :#{ds_element.key}, #{image_style.nil? ? ImageUploader : image_style.get_uploader_klass} \n"
        
      elsif ds_element.ftype == "Text"
        meta_string += "field :#{ds_element.key}, :type => String \n"
      else
        meta_string += "field :#{ds_element.key}, :type => #{ds_element.ftype} \n"
      end
      
      # add fields to liquid output
      liquid_string += "'#{ds_element.key}' => self.#{ds_element.key}, \n"
      
      # handle the unique attribute
      if ds_element.unique
        meta_string += "validates_uniqueness_of :#{ds_element.key} \n"
      end
      
      # handle the notnull attribute
      if ds_element.notnull
        meta_string += "validates_presence_of :#{ds_element.key} \n"
      end
    end

    #explore the timestamp to liquid
    if self.time_log
      #TODO need to add the global time format here
      liquid_string += <<-TIMELOG
        'created_at' => self.created_at,
        'updated_at' => self.updated_at,
      TIMELOG
    end

    #liquid_string = liquid_string[0..-4] + "\n" #remove the last ','

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
    klass.d = self
    klass

  end

  def get_klass
    class_name = gen_class_name

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

  private

  def gen_class_name
    EXT_CLASS_PREFIX + self.key.capitalize
  end
  
  def remove_page_relation
    # loop all the pages and delete the related refs
    Page.all.each do |p|
      if p.r_page_ds
        p.r_page_ds.each do |r_page_d|
          if r_page_d.d.id == self.id
            r_page_d.destroy
          end
        end
      end
    end
  end
  
  def remove_collection
    # delete the data in mongodb
    self.get_klass.delete_all
  end
  
  def destroy_klass
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
