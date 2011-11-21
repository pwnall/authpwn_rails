# Loads sub-classes of the Credential model.
#
# We allow the Credential model to be defined in the Rails application, so the
# application can choose the storage model (ActiveRecord vs Mongoid etc.). This
# means that we have to load the classes that inherit from Credential after it's
# defined, which is long after the authpwn_rails engine is loaded.

require 'active_support'

module Credentials
  extend ActiveSupport::Autoload
  
  autoload :Email, 'authpwn_rails/credentials/email.rb'
  autoload :Facebook, 'authpwn_rails/credentials/facebook.rb'
  autoload :Password, 'authpwn_rails/credentials/password.rb'
end
