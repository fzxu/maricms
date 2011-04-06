class Setting
  include Mongoid::Document

	field :application_title
  field :current_theme
	field :date_format
	field :time_format
	field :attachment_max_size, :type => Integer
	field :host_name
	field :ruby_bin_path
	field :gem_bin_path
	field :repo_path
	field :repo_user
	field :repo_group
	
	field :languages, :type => Array  #The languages that the sites currently supports
	field :default_lang
	field :use_client_locale, :type => Boolean
	
	def default_language
	  self.default_lang.gsub(/-/, '_')
	end
end
