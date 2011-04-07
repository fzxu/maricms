class Setting
  include Mongoid::Document

	field :application_title, :type => String
  field :current_theme, :type => String
	field :date_format, :type => String
	field :time_format, :type => String
	field :attachment_max_size, :type => Integer
	field :host_name, :type => String
	field :ruby_bin_path, :type => String
	field :gem_bin_path, :type => String
	field :repo_path, :type => String
	field :repo_user, :type => String
	field :repo_group, :type => String
	
	field :languages, :type => Array  #The languages that the sites currently supports
	field :default_lang, :type => String
	field :use_client_locale, :type => Boolean
	
	def default_language
	  self.default_lang.gsub(/-/, '_')
	end
	
	def to_liquid
    {
      "app_title" => self.application_title,
      "current_theme" => self.current_theme,
      "host_name" => self.host_name,
      "languages" => self.languages,
      "default_lang" => self.default_lang
    }
	end
end
