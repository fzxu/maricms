##
# MariCMS
# Copyright 2011 金盏信息科技(上海)有限公司 | MariGold Information Tech. Co,. Ltd.
# http://www.maricms.com

# This file is part of MariCMS, an open source content management system.

# MariGold MariCMS is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, version 3 of the License.
# 
# Under the terms of the GNU Affero General Public License you must release the
# complete source code for any application that uses any part of MariCMS
# (system header files and libraries used by the operating system are excluded).
# These terms must be included in any work that has MariCMS components.
# If you are developing and distributing open source applications under the
# GNU Affero General Public License, then you are free to use MariCMS.
# 
# If you are deploying a web site in which users interact with any portion of
# MariCMS over a network, the complete source code changes must be made
# available.  For example, include a link to the source archive directly from
# your web site.
# 
# For OEMs, ISVs, SIs and VARs who distribute MariCMS with their products,
# and do not license and distribute their source code under the GNU
# Affero General Public License, MariGold provides a flexible commercial
# license.
# 
# To anyone in doubt, we recommend the commercial license. Our commercial license
# is competitively priced and will eliminate any confusion about how
# MariCMS can be used and distributed.
# 
# MariCMS is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
# details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with MariCMS.  If not, see <http://www.gnu.org/licenses/>.
# 
# Attribution Notice: MariCMS is an Original Work of software created
# by  金盏信息科技(上海)有限公司 | MariGold Information Tech. Co,. Ltd.
##

class D
  include Mongoid::Document
  include Mongoid::Orderable

  # This model is for data source
  field :key, :type => String
  field :name, :type => String
  field :time_log, :type => Boolean
  field :ds_type, :type => String, :default => "List"
  field :ds_view_type, :type => String, :default => "User"

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
    setting = Setting.first

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
        if ds_element.multi_lang
          setting.languages.each do |l|
            meta_string += "mount_uploader :#{ds_element.key}__#{l.gsub(/-/, '_')}, FileUploader \n"
          end
        else
          meta_string += "mount_uploader :#{ds_element.key}__#{setting.default_language}, FileUploader \n"
        end
      elsif ds_element.ftype == "Image"

        # if the related image style has been deleted
        begin
          image_style = ImageStyle.find(ds_element.image_style_id)
        rescue
        end
        
        if ds_element.multi_lang
          setting.languages.each do |l|
            meta_string += "mount_uploader :#{ds_element.key}__#{l.gsub(/-/, '_')}, #{image_style.nil? ? ImageUploader : image_style.get_uploader_klass} \n"
          end
        else
          meta_string += "mount_uploader :#{ds_element.key}__#{setting.default_language}, #{image_style.nil? ? ImageUploader : image_style.get_uploader_klass} \n"
        end
        

      elsif ds_element.ftype == "Text" || ds_element.ftype == "RichText"
        meta_string += add_text_fields(ds_element, setting, "String")
      else
        meta_string += add_text_fields(ds_element, setting)
      end

      meta_string += <<-DEFAULTLANG
        def #{ds_element.key}
          get_field_value(\"#{ds_element.key}\", #{ds_element.multi_lang})
        end
      DEFAULTLANG

      # add fields to liquid output, which is language specific
      liquid_string += "'#{ds_element.key}' => get_field_value(\"#{ds_element.key}\", #{ds_element.multi_lang}), \n"

      if ds_element.ftype == "String" || ds_element.ftype == "Text" || ds_element.ftype == "RichText"
        # handle the unique attribute
        if ds_element.unique
          if ds_element.multi_lang
            setting.languages.each do |l|
              meta_string += "validates_uniqueness_of :#{ds_element.key}__#{l.gsub(/-/, '_')}, :allow_blank => true \n"
            end
          else
            meta_string += "validates_uniqueness_of :#{ds_element.key}__#{setting.default_language}, :allow_blank => true \n"
          end
        end
  
        # handle the notnull attribute
        if ds_element.notnull
          if ds_element.multi_lang
            setting.languages.each do |l|
              meta_string += "validates_presence_of :#{ds_element.key}__#{l.gsub(/-/, '_')} \n"
            end
          else
            meta_string += "validates_presence_of :#{ds_element.key}__#{setting.default_language} \n"
          end
        end
      end
    end

    meta_string += <<-GETFIELD
      def get_field_value(key, multi_lang)
        if multi_lang
          if self.respond_to?(\"#\{key\}__#\{I18n.locale.to_s.gsub(/-/, '_')\}\")
            self.send(\"#\{key\}__#\{I18n.locale.to_s.gsub(/-/, '_')\}\")
          else
            self.send(\"#\{key\}__#{setting.default_language}\") || ""
          end
        else
          self.send(\"#\{key\}__#{setting.default_language}\") || ""
        end
      end
    GETFIELD

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
 
  # add mongoid fields to the model based on the ds structure and the language setting
  def add_text_fields(ds_element, setting, ftype = nil)
    local_meta_string = ""
    if ds_element.multi_lang
      setting.languages.each do |l|
        local_meta_string += "field :#{ds_element.key}__#{l.gsub(/-/, '_')}, :type => #{ftype || ds_element.ftype} \n"
      end
      local_meta_string
    else
      local_meta_string += "field :#{ds_element.key}__#{setting.default_language}, :type => #{ftype || ds_element.ftype} \n"
    end
  end

end
