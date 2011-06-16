if RUBY_VERSION =~ /1\.9/
  require 'yaml'
  YAML::ENGINE.yamler= 'syck'
end

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
MariCMS::Application.initialize!
