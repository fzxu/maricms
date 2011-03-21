# config/initializers/load_config.rb
APP_CONFIG = YAML.load_file(File.join(Rails.root, "config", "config.yml"))[Rails.env]

ELEMENT_TYPES = ["String", "Integer", "DateTime", "Float", "Boolean", "Image", "File", "Text"]

DS_TYPES = ["Standard", "Tree"]
DS_VIEW_TYPES = ["Developer", "User"]

EXT_MODEL_PREFIX = "MG"

ALLOWED_IMAGE_TYPES = ["jpg", "png", "bmp"]

# Initialized all the ds
D.all.each do |d|
  d.gen_klass
end
