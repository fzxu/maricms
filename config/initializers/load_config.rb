# config/initializers/load_config.rb
APP_CONFIG = YAML.load_file(File.join(Rails.root, "config", "config.yml"))[Rails.env]

ELEMENT_TYPES = ["String", "Integer", "DateTime", "Float", "Boolean", "Image", "File", "Text", "RichText", "Relation"]

DS_TYPES = ["List", "Tree", "Single"]
DS_VIEW_TYPES = ["Developer", "User"]

EXT_CLASS_PREFIX = "EMg"
INT_CLASS_PREFIX = "Mg"

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

IMAGE_CONVERT_QUALITY = ["100", "90", "80", "70", "60", "50", "40"]

MOBILE_BROWSERS = ["android", "ipod", "opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]

AVAILABLE_LANGUAGES = ['en-US', 'zh-CN', 'zh-TW', 'ja']

TEMPLATE_VARIABLE_PREFIX = "mg_"
TEMPLATE_DYNAMIC_DS_PREFIX = "mg_d_"

RELATION_TYPE = ["has_one", "has_many", "belongs_to", "has_and_belongs_to_many"]

# load init setting
setting = Setting.first
unless setting
  default_image_style = APP_CONFIG.delete("image_style")
  Setting.create(APP_CONFIG)
  ImageStyle.create(default_image_style)
end

# now, set the default locale
I18n.locale = Setting.first.default_lang

# set host for action mailer
ActionMailer::Base.default_url_options[:host] = Setting.first.host_name

# Initialized all the ds
D.all.each do |d|
  d.get_klass
end

Mongoid.add_language("zh-CN")