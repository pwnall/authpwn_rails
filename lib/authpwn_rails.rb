# :nodoc: namespace
module AuthpwnRails
end

require 'mini_auth_rails/facebook_token.rb'
require 'mini_auth_rails/session.rb'

if defined?(Rails)
  require 'mini_auth_rails/engine.rb'

  # HACK(costan): this works around a known Rails bug
  #     https://rails.lighthouseapp.com/projects/8994/tickets/1905-apphelpers-within-plugin-not-being-mixed-in
  require File.expand_path('../../app/helpers/session_helper.rb', __FILE__)
  ActionController::Base.helper SessionHelper
end
