class D
  include Mongoid::Document

  # This model is for data source
  field :key
  field :name
  field :time_log, :type => Boolean

  embeds_many :ds_elements
  references_and_referenced_in_many :pages

  index :key, :unique => true
  index "ds_elements.key"

  validates_presence_of :key
  validates_uniqueness_of :key

  after_save :gen_klass
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

    klass = Object.const_set(class_name,Class.new)

    meta_string = "include Mongoid::Document \n include Mongoid::Paperclip \n"
    meta_string += <<-ORDER
      field :position, :type => Integer
      
      def move_up
        return if #{class_name}.where(:position.lt => self.position).empty?
        #{class_name}.where(:position => self.position - 1).first.inc(:position, 1)
        inc(:position, -1)
      end
      
      def move_down
        return if #{class_name}.where(:position.gt => self.position).empty?
        #{class_name}.where(:position => self.position + 1).first.inc(:position, -1)
        inc(:position, 1)
      end
      
      before_save :assign_default_position
      after_destroy :move_lower_siblings_up
      
      def assign_default_position
        return unless self.position.nil? || self.parent_id_changed?

        if #{class_name}.all.empty? || #{class_name}.all.collect(&:position).compact.empty?
          self.position = 0
        else
          self.position = #{class_name}.max(:position) + 1
        end
      end

      def move_lower_siblings_up
        #{class_name}.where(:position.gt => self.position).each { |s| s.inc(:position, -1) }
      end            
    ORDER
    
    if self.time_log
      meta_string += "\n include Mongoid::Timestamps \n"
    end

    liquid_string = ""
    self.ds_elements.each do |ds_element|
      if ds_element.ftype == "File"
        meta_string = meta_string + "has_mongoid_attached_file :#{ds_element.key} \n"
      elsif ds_element.ftype == "Image"
        meta_string = meta_string + <<-IMAGEMETA
          has_mongoid_attached_file :#{ds_element.key},
          :styles => #{image_style.inspect},
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
      unless ds_element.ftype == "Date" || ds_element.ftype == "DateTime" || ds_element.ftype == "Time"
        liquid_string += "'#{ds_element.key}' => self.#{ds_element.key}, \n"
      end
    end

    #explore the timestamp to liquid
    if self.time_log
      #TODO need to add the global time format here
      liquid_string += <<-TIMELOG
        'created_at' => self.created_at.nil? ? "" : self.created_at.strftime("#{setting.date_format}"), 
        'updated_at' => self.updated_at.nil? ? "" : self.updated_at.strftime("#{setting.date_format}"),
      TIMELOG
    end

    #liquid_string = liquid_string[0..-4] + "\n" #remove the last ','

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

  private

  def  convert_symbol(inhash)
    inhash.inject({}) do |memo,(k,v)|
      if v.is_a?(Hash)
        v = convert_symbol(v)
      end
      memo[k.to_sym] = v; memo
    end
  end

end
