require 'rubygems'
require 'test/unit'

require 'action_controller'
require 'action_mailer'
require 'active_record'
require 'rails'

require 'fbgraph_rails'
require 'fbgraph_rails/controller'
require 'sqlite3'

require 'mocha/setup'

require 'authpwn_rails'

require 'helpers/view_helpers.rb'
# NOTE: application_controller and action_mailer have to follow view_helpers
require 'helpers/action_controller.rb'
require 'helpers/application_controller.rb'
require 'helpers/action_mailer.rb'
require 'helpers/autoload_path.rb'
require 'helpers/db_setup.rb'
require 'helpers/fbgraph.rb'
require 'helpers/rails.rb'
require 'helpers/routes.rb'

# Simulate Rails' initializer loading.
require 'authpwn_rails/generators/templates/initializer.rb'

# Rails stubbing is only needed by the initializer, and breaks tests.
require 'helpers/rails_undo.rb'
