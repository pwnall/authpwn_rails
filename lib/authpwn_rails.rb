require 'active_support/dependencies'

# :nodoc: namespace
module Authpwn
  extend ActiveSupport::Autoload

  autoload :CredentialModel, 'authpwn_rails/credential_model.rb'
  autoload :CurrentUser, 'authpwn_rails/current_user.rb'
  autoload :Expires, 'authpwn_rails/expires.rb'
  autoload :SessionController, 'authpwn_rails/session_controller.rb'
  autoload :SessionMailer, 'authpwn_rails/session_mailer.rb'
  autoload :SessionModel, 'authpwn_rails/session_model.rb'
  autoload :UserModel, 'authpwn_rails/user_model.rb'

  # Contains extensions to the User model.
  module UserExtensions
    autoload :ApiTokenField, 'authpwn_rails/user_extensions/api_token_field.rb'
    autoload :EmailField, 'authpwn_rails/user_extensions/email_field.rb'
    autoload :PasswordField, 'authpwn_rails/user_extensions/password_field.rb'
  end
end

require 'authpwn_rails/http_basic.rb'
require 'authpwn_rails/http_token.rb'
require 'authpwn_rails/routes.rb'
require 'authpwn_rails/session.rb'
require 'authpwn_rails/test_extensions.rb'

if defined?(Rails)
  require 'authpwn_rails/engine.rb'

  # HACK(pwnall): this works around a known Rails bug
  #     https://rails.lighthouseapp.com/projects/8994/tickets/1905-apphelpers-within-plugin-not-being-mixed-in
  require_relative '../app/helpers/session_helper.rb'
  ActionController::Base.helper SessionHelper
end
