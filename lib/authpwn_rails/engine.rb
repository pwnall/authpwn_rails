require 'authpwn_rails'
require 'rails'

# :nodoc: namespace
module AuthpwnRails

class Engine < Rails::Engine
  generators do
    require 'authpwn_rails/generators/facebook_generator.rb'
    require 'authpwn_rails/generators/session_generator.rb'
    require 'authpwn_rails/generators/users_generator.rb'
  end
end  # class AuthpwnRails::Engine

end  # namespace AuthpwnRails
