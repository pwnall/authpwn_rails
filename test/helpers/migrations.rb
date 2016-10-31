ActiveRecord::Migration.verbose = false
require 'authpwn_rails/generators/templates/001_create_users.rb'
CreateUsers.migrate :up
require 'authpwn_rails/generators/templates/003_create_credentials.rb'
CreateCredentials.migrate :up

# Simulate Rails' autoloading.
require 'authpwn_rails/generators/templates/user.rb'
require 'authpwn_rails/generators/templates/credential.rb'
require 'authpwn_rails/generators/templates/session.rb'
