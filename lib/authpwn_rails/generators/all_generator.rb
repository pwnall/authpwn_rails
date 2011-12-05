# :nodoc: namespace
module Authpwn

# rails g authpwn:all
class AllGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def create_user_model
    copy_file 'user.rb', File.join('app', 'models', 'user.rb')
    copy_file '001_create_users.rb',
        File.join('db', 'migrate', '20100725000001_create_users.rb')
    copy_file 'users.yml', File.join('test', 'fixtures', 'users.yml')
  end
  
  def create_credential_model
    copy_file 'credential.rb', File.join('app', 'models', 'credential.rb')
    copy_file '003_create_credentials.rb',
        File.join('db', 'migrate', '20100725000003_create_credentials.rb')
    copy_file 'credentials.yml',
        File.join('test', 'fixtures', 'credentials.yml')
  end
  
  def create_session_controller
    copy_file 'session_controller.rb',
              File.join('app', 'controllers', 'session_controller.rb')    
    copy_file File.join('session_controller_test.rb'),
              File.join('test', 'functional', 'session_controller_test.rb')

    route "authpwn_session"
    route "root :to => 'session#show'"
  end
  
  def create_session_views
    copy_file File.join('session', 'forbidden.html.erb'),
              File.join('app', 'views', 'session', 'forbidden.html.erb')
    copy_file File.join('session', 'home.html.erb'),
              File.join('app', 'views', 'session', 'home.html.erb')
    copy_file File.join('session', 'new.html.erb'),
              File.join('app', 'views', 'session', 'new.html.erb')
    copy_file File.join('session', 'password_change.html.erb'),
              File.join('app', 'views', 'session', 'password_change.html.erb')
    copy_file File.join('session', 'welcome.html.erb'),
              File.join('app', 'views', 'session', 'welcome.html.erb')
  end
end  # class Authpwn::AllGenerator

end  # namespace Authpwn
