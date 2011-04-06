# config/initializers/load_config.rb
APP_CONFIG = YAML.load_file(File.join(Rails.root, "config", "config.yml"))[Rails.env]

ELEMENT_TYPES = ["String", "Integer", "DateTime", "Float", "Boolean", "Image", "File", "Text"]

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

# Initialized all the ds
D.all.each do |d|
  d.gen_klass
end