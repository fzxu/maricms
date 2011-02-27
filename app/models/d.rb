class D
  include Mongoid::Document

  # This model is for data source
  field :key
  field :name
  field :time_log, :type => Boolean
  field :ds_type, :default => "Custom"

  embeds_many :ds_elements
  # references_one :r_page_d

  index :key, :unique => true
  index "ds_elements.key"

  validates_presence_of :key
  validates_presence_of :ds_type
  validates_uniqueness_of :key
  validates_format_of :key, :with => /\A([A-Za-z][\w]+)\z/

  scope :custom, :where => {:ds_type => "Custom"}
  scope :tab, :where => {:ds_type => "Tab"}
  
  after_save :gen_klass
  before_destroy :remove_page_relation, :remove_collection
  
  def gen_klass
    # convert all the key to symbol due to the paperclip need
    setting = Setting.first
    image_style = convert_symbol(setting.image_style)

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

    # generate the class const and inherit the class with the name = ds_type
    klass = Object.const_set(class_name,Class.new(Object.const_get(self.ds_type) || Object))

    meta_string = ""

    if self.time_log
      meta_string += "\n include Mongoid::Timestamps \n"
    end

    liquid_string = ""
    self.ds_elements.each do |ds_element|
      
      # assemble the model based on the ftype
      if ds_element.ftype == "File"
        meta_string = meta_string + "has_mongoid_attached_file :#{ds_element.key} \n"
      elsif ds_element.ftype == "Image"
        meta_string = meta_string + <<-IMAGEMETA
          has_mongoid_attached_file :#{ds_element.key},
          :styles => #{image_style.inspect},
          :default_url => '/images/missing.png',
          :convert_options => {:all => '-quality 100'} \n
        IMAGEMETA
        image_style.each do |key, style|
          liquid_string = liquid_string + "'#{ds_element.key}_#{key}' => self.#{ds_element.key}.url(:#{key}), \n"
        end
      elsif ds_element.ftype == "Text"
        meta_string += "field :#{ds_element.key}, :type => String \n"
      elsif ds_element.ftype == "Date" || ds_element.ftype == "DateTime" || ds_element.ftype == "Time"
        meta_string += "field :#{ds_element.key}, :type => #{ds_element.ftype} \n"
        liquid_string += <<-TIMELOG
          '#{ds_element.key}' => self.#{ds_element.key}.nil? ? "" : self.#{ds_element.key}.strftime("#{setting.date_format}"),
        TIMELOG
      else
        meta_string += "field :#{ds_element.key}, :type => #{ds_element.ftype} \n"
      end
      
      # add date to liquid output
      unless ds_element.ftype == "Date" || ds_element.ftype == "DateTime" || ds_element.ftype == "Time"
        liquid_string += "'#{ds_element.key}' => self.#{ds_element.key}, \n"
      end
      
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
        {
          #{liquid_string}
        }.merge super
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

  private

  def convert_symbol(inhash)
    inhash.inject({}) do |memo,(k,v)|
      if v.is_a?(Hash)
        v = convert_symbol(v)
      end
      memo[k.to_sym] = v; memo
    end
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
    Mongoid.database.collection(self.get_klass.collection_name).drop
  end
end
