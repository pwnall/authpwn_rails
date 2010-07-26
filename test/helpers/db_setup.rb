ActiveRecord::Base.establish_connection :adapter => 'sqlite3',
                                        :database => ':memory:'
ActiveRecord::Base.configurations = true

ActiveRecord::Migration.verbose = false
require 'authpwn_rails/generators/templates/001_create_users.rb'
CreateUsers.up
require 'authpwn_rails/generators/templates/002_create_facebook_tokens.rb'
CreateFacebookTokens.up

require File.expand_path('../../../app/models/facebook_token.rb', __FILE__)
require File.expand_path('../../../app/models/user.rb', __FILE__)

# :nodoc: open TestCase to setup fixtures
class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
  
  self.fixture_path =
      File.expand_path '../../../lib/authpwn_rails/generators/templates',
                       __FILE__
  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false
  self.pre_loaded_fixtures = false
  fixtures :all
end
