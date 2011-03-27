# config/initializers/load_config.rb
APP_CONFIG = YAML.load_file(File.join(Rails.root, "config", "config.yml"))[Rails.env]

ELEMENT_TYPES = ["String", "Integer", "DateTime", "Float", "Boolean", "Image", "File", "Text"]

DS_TYPES = ["List", "Tree", "Single"]
DS_VIEW_TYPES = ["Developer", "User"]

EXT_CLASS_PREFIX = "EMg"
INT_CLASS_PREFIX = "Mg"

IMAGE_CONVERT_QUALITY = ["100", "90", "80", "70", "60", "50", "40"]


# Initialized all the uploader, it should be initialied before the ds
# ImageStyle.all.each do |is|
#   is.gen_uploader_klass
# end

# Initialized all the ds
D.all.each do |d|
  d.gen_klass
end