require 'active_support/core_ext/numeric/time.rb'

# :nodoc: namespace
module Authpwn

class Engine < Rails::Engine
  config.authpwn = ActiveSupport::OrderedOptions.new

  # Credentials::Password.expires_after
  config.authpwn.password_expiration = nil
  # Tokens::EmailVerification.expires_after
  config.authpwn.email_verification_expiration = 3.days
  # Tokens::PasswordReset.expires_after
  config.authpwn.password_reset_expiration = 3.days
  # Tokens::SessionUid.expires_after
  config.authpwn.session_expiration = 14.days
  # Tokens::SessionUid.updates_after
  config.authpwn.session_precision = 14.days

  generators do
    require 'authpwn_rails/generators/all_generator.rb'
  end

  initializer 'authpwn.rspec.extensions' do
    begin
      require 'rspec'

      RSpec.configure do |c|
        c.include Authpwn::TestExtensions
        c.include Authpwn::ControllerTestExtensions
      end
    rescue LoadError
      # No RSpec, no extensions.
    end
  end
end  # class Authpwn::Engine

end  # namespace Authpwn
