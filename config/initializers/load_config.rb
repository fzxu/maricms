# config/initializers/load_config.rb
APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]

ELEMENT_TYPES = ["String", "Integer", "DateTime", "Float", "Boolean", "Image", "File", "Text"]

DS_TYPES = ["Custom", "Tab"]
