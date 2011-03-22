class Setting
  include Mongoid::Document

  DATE_FORMATS = [
    '%Y-%m-%d',
    '%d/%m/%Y',
    '%d.%m.%Y',
    '%d-%m-%Y',
    '%m/%d/%Y',
    '%d %b %Y',
    '%d %B %Y',
    '%b %d, %Y',
    '%B %d, %Y'
  ]

  TIME_FORMATS = [
    '%H:%M',
    '%I:%M %p'
  ]

	field :application_title
  field :current_theme
	field :date_format
	field :time_format
	field :attachment_max_size, :type => Integer
	field :host_name
end
