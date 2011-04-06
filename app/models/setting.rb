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
	field :default_language
	field :use_client_locale, :type => Boolean
end
