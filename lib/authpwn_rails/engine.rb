require 'authpwn_rails'
require 'rails'

# :nodoc: namespace
module AuthpwnRails

class Engine < Rails::Engine
  paths.app                 = "app"
  paths.app.controllers     = "app/controllers"
  paths.app.helpers         = "app/helpers"
  paths.app.models          = "app/models"
  paths.app.views           = "app/views"
  # paths.lib                 = "lib"
  # paths.lib.tasks           = "lib/tasks"
  # paths.config              = "config"
  # paths.config.initializers = "config/initializers"
  # paths.config.locales      = "config/locales"
  # paths.config.routes       = "config/routes.rb"
  
  generators do
    require 'authpwn_rails/generators/facebook_generator.rb'
    require 'authpwn_rails/generators/session_generator.rb'
    require 'authpwn_rails/generators/users_generator.rb'
  end
end  # class AuthpwnRails::Engine

end  # namespace AuthpwnRails
