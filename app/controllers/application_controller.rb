class ApplicationController < ActionController::Base
  protect_from_forgery
  def get_theme
    APP_CONFIG['theme']
  end
end
