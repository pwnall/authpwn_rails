require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'minitest/autorun'

require 'action_controller'
require 'action_mailer'
require 'active_record'
require 'active_support/core_ext'
require 'rails'

require 'mocha/setup'

require 'authpwn_rails'

require 'helpers/view_helpers.rb'
# NOTE: application_controller and action_mailer have to follow view_helpers
require 'helpers/action_controller.rb'
require 'helpers/application_controller.rb'
require 'helpers/action_mailer.rb'
require 'helpers/autoload_path.rb'
require 'helpers/db_setup.rb'
require 'helpers/i18n.rb'
require 'helpers/migrations.rb'
require 'helpers/rails.rb'
require 'helpers/routes.rb'
require 'helpers/test_order.rb'

# Simulate Rails' initializer loading.
require 'authpwn_rails/generators/templates/initializer.rb'

# Simulate Rails' autoloading.
require 'authpwn_rails/generators/templates/session_mailer.rb'
require 'authpwn_rails/generators/templates/session_controller.rb'

# Rails stubbing is only needed by the initializer, and breaks tests.
require 'helpers/rails_undo.rb'
