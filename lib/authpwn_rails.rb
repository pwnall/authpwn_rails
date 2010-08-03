# :nodoc: namespace
module AuthpwnRails
end

require 'authpwn_rails/facebook_token.rb'
require 'authpwn_rails/session.rb'

if defined?(Rails)
  require 'authpwn_rails/engine.rb'

  # HACK(costan): this works around a known Rails bug
  #     https://rails.lighthouseapp.com/projects/8994/tickets/1905-apphelpers-within-plugin-not-being-mixed-in
  require File.expand_path('../../app/helpers/session_helper.rb', __FILE__)
  ActionController::Base.helper SessionHelper
end
