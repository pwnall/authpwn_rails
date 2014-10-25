ar_config = { adapter: 'sqlite3', database: ':memory:'}

case ENV['DB']
when /mysql/i
  create_sql = 'CREATE DATABASE plugin_dev DEFAULT CHARACTER SET utf8;'
  if /:(.*)$/ =~ ENV['DB']
    create_sql.sub! ';', " DEFAULT COLLATE #{$1};"
  end

  `mysql -u root -e "DROP DATABASE IF EXISTS plugin_dev; #{create_sql}"`
   ar_config = { adapter: 'mysql2', database: 'plugin_dev',
                 username: 'root', password: '' }
when /pg/i
  pg_user = ENV['DB_USER'] || ENV['USER']
  `psql -U #{pg_user} -d postgres -c "DROP DATABASE IF EXISTS plugin_dev;"`
  `psql -U #{pg_user} -d postgres -c "CREATE DATABASE plugin_dev;"`
  ar_config = { adapter: 'postgresql', database: 'plugin_dev',
                username: pg_user, password: '' }
end

ActiveRecord::Base.configurations = { 'test' => ar_config }
ActiveRecord::Base.establish_connection :test

ActiveRecord::Migration.verbose = false
require 'authpwn_rails/generators/templates/001_create_users.rb'
CreateUsers.migrate :up
require 'authpwn_rails/generators/templates/003_create_credentials.rb'
CreateCredentials.migrate :up

require 'authpwn_rails/generators/templates/user.rb'
require 'authpwn_rails/generators/templates/credential.rb'
require 'authpwn_rails/generators/templates/session.rb'

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
